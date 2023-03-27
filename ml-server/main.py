from fastapi import FastAPI, status, HTTPException, Response, File, UploadFile, Depends
from fastapi.security.api_key import APIKey
import tensorflow as tf

from utils_new import Pitch, PitchGraphGenerator, SemanticEngine
from model import ScoreRequest
import auth

from dotenv import load_dotenv
import logging
import httpx
import os
import urllib


logging.config.fileConfig('logging.conf', disable_existing_loggers=False)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

# Ignore warning about tensorflow
tf.get_logger().setLevel(logging.ERROR)
logger.info('Starting server...')

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(verbose=True)

model = PitchGraphGenerator()
logger.info('SPICE Model loaded')
engine = SemanticEngine("jhgan/ko-sroberta-multitask", "data/sentences.csv")
logger.info('Semantic Engine loaded')

sampling_rate = int(os.getenv('SAMPLING_RATE'))

app = FastAPI()


@app.get('/tts')
async def get_tts_wav_from_clova(text = None, api_key: APIKey = Depends(auth.get_api_key)):
    logger.info('[/tts] called; text: {}'.format(text))

    if text is None:
        logger.error('[/tts] an error occurred; text is required')
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='text is required')
    
    enc_text = urllib.parse.quote(text)
    clova_voice_api_url = os.getenv('CLOVA_VOICE_API_URL')
    key_id = os.getenv('X_NCP_APIGW_API_KEY_ID')
    secret_key = os.getenv('X_NCP_APIGW_API_KEY')
    speaker = os.getenv('SPEAKER')
    output_format = os.getenv('FORMAT')

    data = "speaker={}&volume=0&speed=0&pitch=0&format={}&text={}&sampling-rate={}".format(speaker, output_format, enc_text, sampling_rate)
    
    async with httpx.AsyncClient() as client:
        response = await client.post(clova_voice_api_url, data=data.encode('utf-8'), headers={
            'X-NCP-APIGW-API-KEY-ID': key_id,
            'X-NCP-APIGW-API-KEY': secret_key,
            'Content-Type': 'application/x-www-form-urlencoded'
        })
    
    res_code = response.status_code
    if (res_code != 200):
        logger.error('[/tts] CLOVA Voice API Error code: {}'.format(res_code))
        raise HTTPException(status_code=res_code, detail='Error code: {}'.format(res_code))
    
    logger.info('[/tts] TTS wav 저장. text: {}'.format(text))
    response_body = response.content
    with open('audio/{}.wav'.format(text), 'wb') as f:
        f.write(response_body)

    return Response(content=response_body, media_type='audio/x-www-form-urlencoded')


@app.post('/pitch-graph')
def get_pitch_graph(audio: UploadFile = File(...), api_key: APIKey = Depends(auth.get_api_key)):
    logger.info('[/pitch-graph] called')

    if audio.file is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='audio file(wav) is required')
    
    raw_audio_file = audio.file.read()

    pitch = model.get_pitch(raw_audio_file, confidence_threshold=0.9)
    pitch = pitch.smooth()

    response_body = {
        'pitch_x': pitch.x.tolist(),
        'pitch_y': pitch.y.tolist(),
        'pitch_length': len(pitch.x)
    }

    return response_body


@app.post('/score')
def calculate_pitch_score(score_request: ScoreRequest, api_key: APIKey = Depends(auth.get_api_key)):
    logger.info('[/score] called')
    logger.info('[/score] score_request: {}'.format(score_request))
    pitch_data = score_request.dict()

    if len(pitch_data['target_pitch_x']) != len(pitch_data['target_pitch_y']):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='target pitch data is invalid: x, y length is not same')
    if len(pitch_data['user_pitch_x']) != len(pitch_data['user_pitch_y']):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='user pitch data is invalid: x, y length is not same')
    
    target_pitch = Pitch(pitch_data['target_pitch_x'], pitch_data['target_pitch_y'], label='target')
    user_pitch = Pitch(pitch_data['user_pitch_x'], pitch_data['user_pitch_y'], label='user')

    DTW_score = target_pitch.get_DTW_distance(user_pitch)

    logger.info('[/score] calculated DTW score: {}'.format(DTW_score))
    
    return {
        'DTW_score': DTW_score
    }


@app.get('/semantic-search')
def sementic_search(query: str,
                    top_n: int = 3,
                    is_excluding_exact_result: bool = True,
                    n_of_exact_result: int = 0,
                    api_key: APIKey = Depends(auth.get_api_key)):
    logger.info('[/semantic-search] called; query: {}'.format(query))
    result = engine.search(query=query,
                           is_excluding_exact_result=is_excluding_exact_result,
                           n_of_exact_result=n_of_exact_result,
                           top_n=top_n)
    logger.info('[/semantic-search] result: {}'.format(result))

    return result
