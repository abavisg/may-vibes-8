from dotenv import load_dotenv, find_dotenv
# Load environment variables from nearest .env file
load_dotenv(find_dotenv())
from fastapi import FastAPI
import os
from fastapi.responses import FileResponse, Response
from routers.health import router as health_router
from routers.reframe import router as reframe_router
from routers.categories import router as categories_router
from routers.journal import router as journal_router

# Initialize FastAPI app
app = FastAPI(
    title="MindFlip Backend",
    description="API for thought reframing and journaling",
    version="0.1.0"
)

# Include modular routers
app.include_router(health_router)
app.include_router(reframe_router)
app.include_router(categories_router)
app.include_router(journal_router)

# Favicon endpoint to avoid 404s
@app.get("/favicon.ico", include_in_schema=False)
async def favicon():
    # Path to favicon in static directory
    path = os.path.join(os.path.dirname(__file__), "static", "favicon.ico")
    if os.path.exists(path):
        return FileResponse(path)
    return Response(status_code=204) 