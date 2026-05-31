from fastapi import APIRouter, UploadFile, File, HTTPException
from app.utils.extractor import extract_text
from app.utils.chunker import get_text_chunks
from app.utils.vector_store import add_to_vector_store

router = APIRouter()


@router.post("/upload")
async def upload_document(file: UploadFile = File(...)):
    try:
        content = await file.read()
        text = await extract_text(file_content=content, file_name=file.filename)
        chunks = get_text_chunks(text)
        add_to_vector_store(chunks=chunks, file_name=file.filename)
        return {
            "filename": file.filename,
            "message": f"Successfully added {len(chunks)} chunk(s) into chroma database",
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
