1. Pull Model from ollama:

- Windows:

  ```cmd
  curl -X POST "http://localhost:8000/api/v1/models/pull" -H "Content-Type: application/json" -d "{\"name\":\"qwen2.5:0.5b\"}"
  ```

- Linux/MacOS:

  ```bash
  curl -X POST "http://localhost:8000/api/v1/models/pull" -H "Content-Type: application/json" -d '{"name":"qwen2.5:0.5b"}'
  ```
