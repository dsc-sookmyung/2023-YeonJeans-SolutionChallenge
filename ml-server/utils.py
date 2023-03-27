import numpy as np
import pandas
from pandas import DataFrame, Series
from scipy.signal import savgol_filter
import scipy.fftpack as fftpack
import matplotlib.pyplot as plt
from pydub import AudioSegment
import faiss
from sentence_transformers import SentenceTransformer
import dtw

import math


NAN = -1

sentences = pandas.read_csv('data/sentences.csv')


model = SentenceTransformer("jhgan/ko-sroberta-multitask")
encoded_data = model.encode(sentences["sentence"])
index = faiss.IndexIDMap(faiss.IndexFlatIP(768))
index.add_with_ids(encoded_data, np.array(sentences["id"]))
faiss.write_index(index, 'sentences.index')

print("SROBERTa model loaded")


def convert_audio_for_model(user_file, output_file='converted_audio_file.wav', sampling_rate=16000):
  audio = AudioSegment.from_file(user_file)
  audio = audio.set_frame_rate(sampling_rate).set_channels(1)
  audio.export(output_file, format='wav')
  return output_file


def smooth_data_savgol_2(arr, span):  
    return savgol_filter(arr, span, 2)


def smooth_data_fft(arr, span):
    w = fftpack.rfft(arr)
    spectrum = w ** 2
    cutoff_idx = spectrum < (spectrum.max() * (1 - np.exp(-span / 2000)))
    w[cutoff_idx] = 0
    return fftpack.irfft(w)


def smooth(graph):
    # pitch_y 데이터를 smoothing한다.
    smoothed_pitch_y = smooth_data_fft(graph["pitch_y"], 1.2)
    smoothed_pitch_y = smoothed_pitch_y.tolist()
    graph["pitch_y"] = smoothed_pitch_y
    # print(graph)
    return graph


def fill_gap(graph, start = 0, end = None, fill_with = NAN):
    # pitch_x가 빈 값 없이 연속적인 정수 값을 갖도록 바꾸고,
    # pitch_y 데이터 중 비어있는 값을 fill_with로 채운다.
    pitch_x, pitch_y = graph["pitch_x"], graph["pitch_y"]

    if len(pitch_x) == 0 and len(pitch_y) == 0:
        return None

    pitch_x_last_value = pitch_x[-1]

    if end is None:
        end = pitch_x_last_value

    filled_pitch_x = list(range(start, end + 1))
    filled_pitch_y = [fill_with] * (end - start + 1)

    for i, x in enumerate(pitch_x):
        filled_pitch_y[x - start] = pitch_y[i]

    graph['pitch_x'] = filled_pitch_x
    graph['pitch_y'] = filled_pitch_y

    return graph


def scale(graph, target_length):
    # 더 짧은 그래프의 길이를 더 긴 그래프의 길이에 맞춰서 pitch_x의 값들을 scale한다.

    if graph is None or len(graph["pitch_x"]) == 0 or len(graph["pitch_y"]) == 0:
        return None
    if target_length < len(graph["pitch_x"]):
        return graph
    
    scale_factor = (target_length - 1) / (len(graph["pitch_x"]) - 1)
    graph["pitch_x"] = [math.ceil(x * scale_factor) for x in graph["pitch_x"]]
    graph = fill_gap(graph, start=graph["pitch_x"][0], end=graph["pitch_x"][-1])

    return graph


def interpolate(graph, target=[ NAN ], method="values"):
    # target으로 채워진 값을 보간한다.

    ts = Series(graph["pitch_y"], index=graph["pitch_x"])

    ts.replace(target, np.nan, inplace=True)
    ts.interpolate(method=method, inplace=True)
    ts.replace(target, np.nan, inplace=True)

    graph["pitch_y"] = ts.tolist()

    return graph
    

def get_MAPE_score(graph_1, graph_2):
    # 두 그래프의 길이를 긴 쪽에 맞추어 같도록 한 후 보간한다..
    shorter_graph, longer_graph = sorted([graph_1, graph_2], key=lambda x: len(x["pitch_x"]))

    target_length = len(longer_graph["pitch_x"])
    shorter_graph = scale(shorter_graph, target_length)

    shorter_graph = interpolate(shorter_graph)
    longer_graph = interpolate(longer_graph)

    # MAPE를 계산한다.
    target_y = DataFrame(shorter_graph["pitch_y"] if shorter_graph["label"] == "target" else longer_graph["pitch_y"])
    user_y = DataFrame(shorter_graph["pitch_y"] if shorter_graph["label"] == "user" else longer_graph["pitch_y"])

    MAPE = np.mean(np.abs((target_y - user_y) / target_y)) * 100

    if MAPE[0] in [np.nan, np.inf, -np.inf]:
        MAPE[0] = 100
    
    score = 100 - MAPE[0]
    # print("MAPE: ", MAPE)
    return score


def get_DTW_score(graph_1, graph_2):
    score = dtw.dtw(graph_1["pitch_y"], graph_2["pitch_y"], keep_internals=True)
    return score.distance


def compare(target, user):
    target = interpolate(fill_gap(target, start=target['pitch_x'][0], end=target['pitch_x'][-1]))
    user = interpolate(fill_gap(user, start=user['pitch_x'][0], end=user['pitch_x'][-1]))

    DTW_score = get_DTW_score(target, user)
    MAPE_score = get_MAPE_score(target, user)
    
    # print("DTW: ", DTW_score)
    # print("MAPE: ", MAPE_score)
    return MAPE_score, DTW_score


def draw_graph(graph):
    # resize graph
    plt.figure(figsize=(14, 8))
    # graph['pitch_y'] = [ np.nan if x == -1.0 else x for x in graph['pitch_y']]
    plt.plot(graph["pitch_x"], graph["pitch_y"], label="y")
    smoothed_y = smooth(graph)["pitch_y"]
    plt.plot(graph["pitch_x"], smoothed_y, label="smoothed_y")

    plt.legend()
    plt.show()


def create_id_to_sen_dict():
    id_to_sen = {}
    for i in range(len(sentences)):
        id_to_sen[sentences["id"][i]] = sentences["sentence"][i]
    return id_to_sen


def create_sen_to_id_dict():
    sen_to_id = {}
    for i in range(len(sentences)):
        sen_to_id[sentences["sentence"][i]] = sentences["id"][i]
    return sen_to_id


def semantic_sentence_search(query: str, is_excluding_exact_result: bool, n_of_exact_result: int, top_n: int = 3):
    id_to_sen = create_id_to_sen_dict()

    if is_excluding_exact_result and not n_of_exact_result:
        # query를 포함하는 문장의 개수를 구한다.
        # 문장이 많아지면 실행 시간이 오래 걸리니 가능하면 스프링에서 n_of_containing_query를 넘겨주는 것이 좋다.
        n_of_exact_result = len([sen for sen in sentences["sentence"] if query in sen])

    if top_n + n_of_exact_result > len(sentences):
        raise Exception("top_n + n_of_exact_result is greater than the number of sentences.")
    
    query_vector = model.encode([query])
    top_n_sentences_id = index.search(query_vector, top_n + n_of_exact_result)
    # top_n_sentences_id에서 query를 포함하는 문장을 제외한다.
    top_n_sentences_id = [s_id for s_id in top_n_sentences_id[1][0] if query not in id_to_sen[s_id]]
    
    return {
        str(i): {
            "id": str(s_id),
            "sentence": id_to_sen[s_id],
        } for i, s_id in enumerate(top_n_sentences_id[:top_n])
    }
