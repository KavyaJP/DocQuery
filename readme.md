# Automatic Smart Document

## TechStack

- Backend:
  - Python FastAPI
  - Tesseract for OCR
  - Ollama for LLM inference support

## Development Environment Setup Process

1.  Create & activate virtual environment:

```bash
python -m venv venv
```

- **Windows:**

  ```bash
  .venv\Scripts\activate.bat
  ```

- **Linux & MacOS:**

  ```bash
  source .venv/bin/activate
  ```

2.  Download the libraries required for backend:

```bash
pip3 install -r requirements.txt
```

3.  Download tesseract OCR engine

- **Windows:** Go to [this page](https://github.com/UB-Mannheim/tesseract/wiki) and download the latest setup and install it and put the path of tesseract.exe in `.env`

- **macOS (via Homebrew):**

  ```bash
  brew install tesseract
  ```

- **Linux (Ubuntu/Debian):**

  ```bash
  sudo apt-get update
  sudo apt-get install tesseract-ocr
  ```

## LICENSE

This project is licensed under [MIT LICENSE](LICENSE)
