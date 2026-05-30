from fastapi import APIRouter, UploadFile, File, HTTPException
from app.utils.extractor import extract_text

router = APIRouter()


@router.post("/upload")
async def upload_document(file: UploadFile = File(...)):
    try:
        content = await file.read()
        text = await extract_text(file_content=content, file_name=file.filename)
        return {"filename": file.filename, "extracted_text": text}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
