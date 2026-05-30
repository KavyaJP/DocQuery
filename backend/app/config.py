import os
from pathlib import Path
from dotenv import load_dotenv

current_file = Path(__file__).resolve()
backend_path = current_file.parent.parent
env_path = backend_path / ".env"

load_dotenv(dotenv_path=env_path)

TESSERACT_PATH = os.getenv("tesseract_path")
