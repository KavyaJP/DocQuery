After Starting the application, you can visit [http://localhost:8000/docs#/](http://localhost:8000/docs#/) to view full documentation of every API

1. Pull Model from ollama:

- Windows:

  ```cmd
  curl -X POST "http://localhost:8000/api/v1/models/pull" -H "Content-Type: application/json" -d "{\"name\":\"qwen2.5:0.5b\"}"
  ```

- Linux/MacOS:

  ```bash
  curl -X POST "http://localhost:8000/api/v1/models/pull" -H "Content-Type: application/json" -d '{"name":"qwen2.5:0.5b"}'
  ```

**Returns:** A stream of `{"status":"pulling c5396e06af29","digest":"sha256:c5396e06af294bd101b30dce59131a76d2b773e76950acc870eda801d3ab0515","total":397807936,"completed":80949}`

2. Extract Text from document and store it into ChromaDB:

```bash
curl -X POST "http://localhost:8000/api/v1/documents/upload" -F "file=@E:\Programs\AI-Document-Automation\test_documents\test_pdf.pdf"
```

**Returns:** `{"filename":"test_pdf.pdf","message":"Successfully added 1 chunk(s) into chroma database"}`
