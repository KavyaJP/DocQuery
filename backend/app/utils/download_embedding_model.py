from pathlib import Path
from huggingface_hub import snapshot_download
from app.config import MODEL_DIR

def download_model():
    print("Downloading embedding model weights completely to the local directory...")

    snapshot_download(
        repo_id="sentence-transformers/all-MiniLM-L6-v2",
        local_dir=MODEL_DIR,
        local_dir_use_symlinks=False,
    )

    print(f"Download complete! Model weights stored locally at: {MODEL_DIR}")
