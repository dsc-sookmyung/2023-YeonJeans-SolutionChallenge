from fastapi.security.api_key import APIKeyHeader
from fastapi import Security, HTTPException
from starlette.status import HTTP_403_FORBIDDEN

from dotenv import load_dotenv
import os

load_dotenv(verbose=True)

API_KEY = os.getenv('API_KEY')
api_key_header = APIKeyHeader(name='Access-Token', auto_error=False)


async def get_api_key(api_key_header: str = Security(api_key_header)):
    if api_key_header == API_KEY:
        return api_key_header
    else:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN, detail="Could not validate credentials"
        )
