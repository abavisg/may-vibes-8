from fastapi import APIRouter
from typing import List
from services.categories import get_categories

router = APIRouter()

@router.get("/categories", response_model=List[str], tags=["Categories"])
async def list_categories():
    """
    Get the fixed list of thought reframing categories.
    """
    return get_categories() 