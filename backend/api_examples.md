After starting the application, visit `http://localhost:8000/docs#/` to access the complete API documentation and explore all available endpoints.

## Ollama APIs

### 1. Pull a Model

Download an Ollama model for local inference.

- **Windows:**

  ```cmd
  curl -X POST "http://localhost:8000/api/v1/models/pull" -H "Content-Type: application/json" -d "{\"name\":\"qwen2.5:0.5b\"}"
  ```

- **Linux & MacOS:**

  ```bash
  curl -X POST "http://localhost:8000/api/v1/models/pull" -H "Content-Type: application/json" -d '{"name":"qwen2.5:0.5b"}'
  ```

**Returns:** A stream of `{"status":"pulling c5396e06af29","digest":"sha256:c5396e06af294bd101b30dce59131a76d2b773e76950acc870eda801d3ab0515","total":397807936,"completed":80949}`

### 2. Remove a Model

Remove a previously downloaded Ollama model.

- **Windows:**

  ```cmd
  curl -X POST "http://localhost:8000/api/v1/models/remove" -H "Content-Type: application/json" -d "{\"name\":\"qwen2.5:0.5b\"}"
  ```

- **Linux & MacOS:**

  ```bash
  curl -X POST "http://localhost:8000/api/v1/models/remove" -H "Content-Type: application/json" -d '{"name":"qwen2.5:0.5b"}'
  ```

**Returns:** `{"Status":200,"Message":"Model qwen2.5:0.5b deleted successfully"}`

## Text Extraction & Vectorisation API

Upload a document to extract text and store embeddings in ChromaDB.

```bash
curl -X POST "http://localhost:8000/api/v1/documents/upload" -F "file=@E:\Programs\AI-Document-Automation\test_documents\test_pdf.pdf"
```

**Returns:** `{"filename":"test_pdf.pdf","message":"Successfully added 1 chunk(s) into chroma database"}`

## Query API

Submit a question and receive an LLM-generated answer using retrieved document context.

- **Windows:**

  ```bash
  curl -X POST "http://localhost:8000/api/v1/chat/ask" -H "Content-Type: application/json" -d "{\"query\": \"Who wrote the smart document workflow testing PDF?\", \"model_name\":\"qwen2.5:0.5b\"}"
  ```

- **Linux & MacOS:**

  ```bash
  curl -X POST "http://localhost:8000/api/v1/chat/ask" -H "Content-Type: application/json" -d "{"query": "Who wrote the smart document workflow testing PDF?", "model_name":"qwen2.5:0.5b"}"
  ```

**Returns:** `{"question":"Who wrote the smart document workflow testing PDF?","answer":"The smart document workflow testing PDF was written by Kavya Prajapati.","context_used":"Smart Document Workflow Test PDF \nAbout \nThis is the pdf used for smart document workflow testing \nWritten by \nKavya Prajapati"}`
