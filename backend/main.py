from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv
import os

# Load environment variables
load_dotenv()

# Initialize FastAPI app
app = FastAPI(
    title="MindFlip Backend",
    description="API for thought reframing and journaling",
    version="0.1.0"
)

# Pydantic models
class ReframeRequest(BaseModel):
    thought: str

class ReframeResponse(BaseModel):
    suggestions: List[str]
    tag: str

# Health check endpoint
@app.get("/", tags=["Health"])
async def root():
    return {"message": "MindFlip backend is running."}

# Thought reframing endpoint
@app.post("/reframe", response_model=ReframeResponse, tags=["Reframe"])
async def reframe(request: ReframeRequest):
    """
    Receive a negative thought and return 3 positive reframe suggestions and an auto-generated tag.
    """
    # TODO: Integrate with Ollama LLM via local API or subprocess
    # For now, return stubbed suggestions
    suggestions = [
        f"Positive reframe 1 for: {request.thought}",
        f"Positive reframe 2 for: {request.thought}",
        f"Positive reframe 3 for: {request.thought}",
    ]
    tag = "Stub-Tag"
    return ReframeResponse(suggestions=suggestions, tag=tag) 