from fastapi import APIRouter, HTTPException
from typing import Dict
from models import JournalEntryRequest, JournalEntryResponse
from services.journal import save_entry

router = APIRouter()

@router.post("/entries", response_model=JournalEntryResponse, tags=["Journal"])
async def create_entry(request: JournalEntryRequest) -> Dict:
    """
    Save a reframed thought entry to the journal.
    """
    try:
        entry = save_entry(request.original_thought, request.suggestion, request.tag)
    except HTTPException as e:
        raise e
    return entry 