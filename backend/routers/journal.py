from fastapi import APIRouter, HTTPException
from typing import Dict, List
from models import JournalEntryRequest, JournalEntryResponse
from services.journal import save_entry, get_entries

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

@router.get("/entries", response_model=List[JournalEntryResponse], tags=["Journal"])
async def list_entries() -> List[Dict]:
    """
    Retrieve all journal entries.
    """
    try:
        entries = get_entries()
    except HTTPException as e:
        raise e
    # Convert dictionaries to JournalEntryResponse models for validation and typing
    return [JournalEntryResponse(**entry) for entry in entries] 