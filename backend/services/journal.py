import os
from supabase import create_client, Client
from fastapi import HTTPException
from typing import Any, Dict

# Initialize Supabase client
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
if not SUPABASE_URL or not SUPABASE_KEY:
    raise RuntimeError("SUPABASE_URL and SUPABASE_KEY must be set in environment")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def save_entry(original_thought: str, suggestion: str, tag: str) -> Dict[str, Any]:
    """
    Save a reframed thought to the Supabase 'entries' table.
    Returns the inserted row.
    """
    try:
        payload = {
            "original_thought": original_thought,
            "reframed_text": suggestion,
            "category": tag
        }
        response = supabase.from_("entries").insert(payload).select("*").execute()
        data = response.data
        if data and isinstance(data, list):
            return data[0]
        raise HTTPException(status_code=500, detail="Failed to save journal entry")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) 