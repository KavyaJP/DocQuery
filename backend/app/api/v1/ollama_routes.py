import httpx
import json

from fastapi import APIRouter
from pydantic import BaseModel
from fastapi.responses import StreamingResponse


class PullModelRequest(BaseModel):
    name: str


async def stream_ollama_pull(model_name: str):
    async with httpx.AsyncClient(timeout=None) as client:
        async with client.stream(
            "POST",
            "http://localhost:11434/api/pull",
            json={"name": model_name, "stream": True},
        ) as response:
            async for chunk in response.aiter_lines():
                if chunk:
                    yield f"{chunk}\n\n"


router = APIRouter()


@router.get("/local_models")
async def local_models():
    async with httpx.AsyncClient() as client:
        response = await client.get("http://localhost:11434/api/tags")
        response.raise_for_status()
        return response.json()


@router.get("/recommended_models")
def recommended_models():
    return {
        "no_vram": "qwen3.5:2b",
        "4gb_vram": "qwen3.5:4b",
        "6gb_vram": "qwen3.5:4b",
        "8gb_vram": "qwen3.5:9b",
        "12gb_vram": "qwen3.5:9b",
        "16gb_vram": "qwen3.5:9b",
        "24gb_vram": "qwen3.6:27b",
        "48gb_vram": "qwen3.5:35b",
        "72gb_plus_vram": "qwen3.5:122b",
    }


@router.post("/pull")
async def pull_model(request: PullModelRequest):
    return StreamingResponse(
        stream_ollama_pull(request.name), media_type="text/event-stream"
    )
