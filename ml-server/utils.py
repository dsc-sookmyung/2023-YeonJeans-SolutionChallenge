import numpy as np
import pandas
from pandas import DataFrame, Series
import tensorflow as tf
import tensorflow_hub as hub
from scipy.io import wavfile
from scipy.signal import savgol_filter
import scipy.fftpack as fftpack
import matplotlib.pyplot as plt
from pydub import AudioSegment
import faiss
from sentence_transformers import SentenceTransformer
import dtw

import os
import datetime
import math


class Pitch:
    def __init__(self, x, y, label = None):
        if len(x) != len(y):
            raise Exception('Pitch x and y length mismatch')

        self.x = x
        self.y = y
        self.label = label
    
    
    def __str__(self):
        return f'{self.label}: \n\tx: {self.x}, \n\ty: {self.y}'
    
    
    def smooth_data_savgol(self, arr, span):
        return savgol_filter(arr, span, 2)
    

    def smooth_data_fft(self, arr, span):
        w = fftpack.rfft(arr)
        spectrum = w ** 2
        cutoff_idx = spectrum < (spectrum.max() * (1 - np.exp(-span / 2000)))
        w[cutoff_idx] = 0
        return fftpack.irfft(w)
    

    def smooth(self, smoothing_algorithm='fft'):
        # pitch_y 데이터를 smoothing한다.
        if smoothing_algorithm not in ['fft', 'savgol']:
            raise Exception('smoothing_algorithm must be "fft" or "savgol"')
        
        smoothing_algorithm = getattr(self, f'smooth_data_{smoothing_algorithm}')

        smoothed_pitch_y = smoothing_algorithm(self.y, 1.2)
        smoothed_pitch_y = smoothed_pitch_y.tolist()

        self.y = smoothed_pitch_y
        # print(graph)


    def fill(self, start = 0, end = None, fill_with = -1):
        # pitch_x가 빈 값 없이 연속적인 정수 값을 갖도록 바꾸고,
        # pitch_y 데이터 중 비어있는 값을 fill_with로 채운다.

        if len(self.x) == 0 and len(self.y) == 0:
            raise Exception('Empty pitch data')

        pitch_x_last_value = self.x[-1]

        if end is None:
            end = pitch_x_last_value

        filled_pitch_x = list(range(start, end + 1))
        filled_pitch_y = [fill_with] * (end - start + 1)

        for i, x in enumerate(self.x):
            filled_pitch_y[x - start] = self.y[i]

        self.x = filled_pitch_x
        self.y = filled_pitch_y


    def scale(self, target_length):
        if target_length < len(self.x):
            raise Exception('Target length is shorter than pitch data')

        scale_factor = (target_length - 1) / (len(self.x) - 1)
        self.x = [math.ceil(x * scale_factor) for x in self.x]
    
    
    def interpolate(self, target=[ -1 ], method="values"):
        # target으로 채워진 값을 보간한다.
        ts = Series(self.y, index=self.x)

        ts.replace(target, np.nan, inplace=True)
        ts.interpolate(method=method, inplace=True)
        ts.replace(target, np.nan, inplace=True)

        self.y = ts.tolist()
    

    def get_DTW_distance(self, other):
        # 전처리
        target = self if self.label == "target" else other
        user = self if self.label == "user" else other

        target.fill(start=target.x[0], end=target.x[-1])
        target.interpolate()

        user.fill(start=user.x[0], end=user.x[-1])
        user.interpolate()

        # DTW distance를 구한다.
        return dtw.dtw(target.y, user.y, keep_internals=True).distance


    def draw(self):
        plt.plot(self.x, self.y)
        plt.show()




class PitchGraphGenerator:
    def __init__(self, sampling_rate=16000, model='https://tfhub.dev/google/spice/2'):
        self.sampling_rate = sampling_rate

        try:
            os.environ["TFHUB_CACHE_DIR"] = ".cache/tfhub"
            self.model = hub.load(model)
        except:
            raise Exception('Model not found')
        

    def convert_audio_for_model(self, user_file, output_file='converted_audio_file.wav', sampling_rate=16000):
        audio = AudioSegment.from_file(user_file)
        audio = audio.set_frame_rate(sampling_rate).set_channels(1)
        audio.export(output_file, format='wav')
        return output_file
    
    
    def get_pitch(self, raw_audio_file, confidence_threshold=0.9):
        random_name = datetime.datetime.now().strftime('%Y%m%d%H%M%S%f')

        with open('audio_pitch/{}.wav'.format(random_name), 'wb') as f:
            f.write(raw_audio_file)

        converted_audio_file = self.convert_audio_for_model('audio_pitch/{}.wav'.format(random_name),
                                                  'audio_pitch/converted_{}.wav'.format(random_name),
                                                  self.sampling_rate)
        _, audio_file = wavfile.read(converted_audio_file, 'rb')
        model_output = self.model.signatures["serving_default"](tf.constant(audio_file, tf.float32))

        pitch_outputs = model_output["pitch"]
        uncertainty_outputs = model_output["uncertainty"]

        # confidence = 1 - uncertainty
        confidence_outputs = list(1.0 - uncertainty_outputs)
        pitch_outputs = [ float(x) for x in pitch_outputs ]

        indices = range(len(pitch_outputs))

        # confidence 0.9 이상인 것만 추출
        confident_pitch_outputs = [ (i, p) for i, p, c in zip(indices, pitch_outputs, confidence_outputs) if c > confidence_threshold ]
        try:
            confident_pitch_outputs_x, confident_pitch_outputs_y = zip(*confident_pitch_outputs)
        except ValueError:
            raise Exception('No confident pitch data')
        
        os.remove('audio_pitch/{}.wav'.format(raw_audio_file_name))
        os.remove('audio_pitch/converted_{}.wav'.format(raw_audio_file_name))

        pitch_graph = Pitch(confident_pitch_outputs_x, confident_pitch_outputs_y)

        return pitch_graph




class SemanticEngine:
    def __init__(self, model_path, csv_path):
        self.model = SentenceTransformer(model_path)
        self.sentences = pandas.read_csv(csv_path)
        self.index = faiss.IndexIDMap(faiss.IndexFlatIP(768))
        self.create_id_to_sen_dict()

        encoded_data = self.model.encode(self.sentences["sentence"])
        self.index.add_with_ids(encoded_data, np.array(self.sentences["id"]))
    

    def create_id_to_sen_dict(self):
        self.id_to_sen = {}
        for i in range(len(self.sentences)):
            self.id_to_sen[self.sentences["id"][i]] = self.sentences["sentence"][i]
    

    def search(self, query: str, is_excluding_exact_result: bool, n_of_exact_result: int, top_n: int):
        if is_excluding_exact_result and not n_of_exact_result:
        # query를 포함하는 문장의 개수를 구한다.
        # 문장이 많아지면 실행 시간이 오래 걸리니 가능하면 스프링에서 n_of_containing_query를 넘겨주는 것이 좋다.
            n_of_exact_result = len([sen for sen in self.sentences["sentence"] if query in sen])

        if top_n + n_of_exact_result > len(self.sentences):
            raise Exception("top_n + n_of_exact_result is greater than the number of sentences.")
        
        query_vector = self.model.encode([query])
        top_n_sentences_id = self.index.search(query_vector, top_n + n_of_exact_result)
        print(top_n_sentences_id[1][0])
        # top_n_sentences_id에서 query를 포함하는 문장을 제외한다.
        top_n_sentences_id = [s_id for s_id in top_n_sentences_id[1][0] if query not in self.id_to_sen[s_id]]
        
        return {
            str(i): {
                "id": str(s_id),
                "sentence": self.id_to_sen[s_id],
            } for i, s_id in enumerate(top_n_sentences_id[:top_n])
        }
