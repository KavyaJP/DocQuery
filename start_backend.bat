call .venv\Scripts\activate.bat
cd backend
uvicorn app.main:app --reload
cd ..