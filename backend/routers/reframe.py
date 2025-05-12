from fastapi import APIRouter
from fastapi import HTTPException
from models import ReframeRequest, ReframeResponse
from services.ollama import reframe_thought

router = APIRouter()

@router.post("/reframe", response_model=ReframeResponse, tags=["Reframe"])
async def reframe(request: ReframeRequest):
    """
    Reframe a negative thought using the Ollama-based LLM integration.
    """
    # Call the service function
    try:
        suggestions, tag = reframe_thought(request.thought)
    except HTTPException as e:
        # Propagate HTTP exceptions
        raise e
    return ReframeResponse(suggestions=suggestions, tag=tag) 