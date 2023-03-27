# Saera-ML
조럽하자! 조럽하자!

## environment
- python 3.9.16
- Linux 환경 권장 - Apple Silicon에서는 실행 불가

## dependencies
- `uvicorn`, `tensorflow`, `tensorflow-hub`은 conda로 설치

```shell
pip3 install -r requirements-ubuntu.txt

```
`requirements.txt`는 Apple Silicon에서 드디어 텐서플로우가 돌아간다는 소문을 듣고 싱글벙글하며 들이박았다가 씁쓸한 에러맛만 본 자의 유산이올시다



## run
- miniconda3 설치 및 실행 필요
- conda 가상환경에서 다음 명령어 실행
- gunicorn 관련 configuration은 `gunicorn.conf.py` 참고

```shell
gunicorn main:app
```
