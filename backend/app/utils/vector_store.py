from langchain_chroma import Chroma

from app.config import DB_PATH, EMBEDDING_MODEL

def add_to_vector_store(chunks: list[str], file_name: str):
    metadatas = [{"source": file_name} for _ in chunks]

    vector_store = Chroma.from_texts(
        texts=chunks,
        embedding=EMBEDDING_MODEL,
        persist_directory=str(DB_PATH),
        metadatas=metadatas,
    )

    return vector_store


def get_relevant_chunks(query: str, k: int = 3) -> list[str]:
    vector_store = Chroma(
        persist_directory=str(DB_PATH), embedding_function=EMBEDDING_MODEL
    )
    results = vector_store.similarity_search(query=query, k=k)
    context_chunks = [doc.page_content for doc in results]
    return context_chunks
