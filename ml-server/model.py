from pydantic import BaseModel

class ScoreRequest(BaseModel):
    target_pitch_x: list
    target_pitch_y: list
    user_pitch_x: list
    user_pitch_y: list
