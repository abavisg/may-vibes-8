from pydantic import BaseModel
from typing import List

class ReframeRequest(BaseModel):
    thought: str

class ReframeResponse(BaseModel):
    suggestions: List[str]
    tag: str 