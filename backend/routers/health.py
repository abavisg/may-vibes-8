from fastapi import APIRouter

router = APIRouter()

@router.get("/", tags=["Health"])
async def health_check():
    return {"message": "MindFlip backend is running."} 