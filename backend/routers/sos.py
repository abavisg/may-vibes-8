from fastapi import APIRouter, HTTPException
from typing import Optional
from services.ollama import get_sos_technique

router = APIRouter()

@router.get("/sos", response_model=str)
def get_sos(feeling: Optional[str] = None):
    """
    Get an immediate coping technique based on the current feeling or situation.
    """
    try:
        technique = get_sos_technique(feeling or "distress") # Provide a default feeling if none is given
        return technique
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 