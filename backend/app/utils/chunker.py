from langchain_text_splitters import RecursiveCharacterTextSplitter


def get_text_chunks(input_text: str):
    text_splitter = RecursiveCharacterTextSplitter(chunk_size=500, chunk_overlap=50)
    chunks = text_splitter.split_text(text=input_text)
    return chunks
