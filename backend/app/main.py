import subprocess
import asyncio
import httpx

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from contextlib import asynccontextmanager

# importing API routes
from app.api.v1 import ollama_routes
from app.api.v1 import document_routes


# Start ollama when starting the application
async def check_if_ollama_running() -> bool:
    async with httpx.AsyncClient() as client:
        try:
            response = await client.get("http://localhost:11434/")
            if response:
                return True
        except:
            return False


@asynccontextmanager
async def lifespan_function(app: FastAPI):
    ollama_process = None
    is_ollama_running = await check_if_ollama_running()
    if not is_ollama_running:
        ollama_process = subprocess.Popen(["ollama", "serve"])
        await asyncio.sleep(2)

        print("\n\nStarted Ollama\n\n")

    yield

    if ollama_process:
        ollama_process.terminate()
        print("\n\nStopped Ollama\n\n")


app = FastAPI(title="Smart Document Workflow API", lifespan=lifespan_function)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(ollama_routes.router, prefix="/api/v1/models")
app.include_router(document_routes.router, prefix="/api/v1/documents")


@app.get("/")
def root():
    return {"status": "ok", "message": "Smart Document Workflow API is working"}
