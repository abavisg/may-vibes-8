import os
from supabase import create_client, Client
from fastapi import HTTPException
from typing import Any, Dict, List

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
        # Perform the insert operation
        response = supabase.from_("entries").insert(payload).execute()
        
        # Check if the response contains data
        if response.data and isinstance(response.data, list):
            return response.data[0]  # Return the first inserted row
        raise HTTPException(status_code=500, detail="Failed to save journal entry")
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def get_entries() -> List[Dict[str, Any]]:
    """
    Retrieve all journal entries from the Supabase 'entries' table.
    Returns a list of dictionaries, each representing a row.
    """
    try:
        # Fetch all rows from the 'entries' table
        # Using .select('*') explicitly to get all columns
        # and .execute() to run the query
        response = supabase.from_("entries").select("*").execute()
        data = response.data
        if data and isinstance(data, list):
            return data
        # Return an empty list if no data is returned or data format is unexpected
        return []
    except Exception as e:
        # Log the error or handle it as needed
        print(f"Error fetching journal entries: {e}")
        # Propagate a standard HTTPException for API consistency
        raise HTTPException(status_code=500, detail="Failed to retrieve journal entries")