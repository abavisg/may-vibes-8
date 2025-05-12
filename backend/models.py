from pydantic import BaseModel
from typing import List
from datetime import datetime

class ReframeRequest(BaseModel):
    thought: str

class ReframeResponse(BaseModel):
    suggestions: List[str]
    tag: str

class JournalEntryRequest(BaseModel):
    original_thought: str
    suggestion: str
    tag: str

class JournalEntryResponse(BaseModel):
    id: int
    original_thought: str
    reframed_text: str
    category: str
    created_at: datetime 