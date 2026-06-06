import os
from dotenv import load_dotenv
from langchain_community.document_loaders import TextLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from langchain_community.vectorstores import Chroma

load_dotenv()

CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))

DOCS_DIR = os.path.join(CURRENT_DIR, 'data')
DB_DIR = os.path.join(CURRENT_DIR, 'vectorad_db')

def build_vector_db():
    print("Iniciando la construcción de la base de datos vectorial del Barista...")

    archivos = ["barista_knowledge.txt"]
    documentos = []

    for archivo in archivos:
        ruta_archivo = os.path.join(DOCS_DIR, archivo)
        if os.path.exists(ruta_archivo):
            print(f"Cargando {archivo}...")
            loader = TextLoader(ruta_archivo, encoding='utf-8')
            documentos.extend(loader.load())
        else:
            print(f"Advertencia: El archivo {archivo} no se encontró en {ruta_archivo}")
    
    if not documentos:
        print("No se cargó ningún documento. Verifica las rutas.")
        return

    print("Dividiendo los documentos en fragmentos...")
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=500,
        chunk_overlap=50,
        length_function=len
    )
    chunks = text_splitter.split_documents(documentos)
    print(f"Se crearon {len(chunks)} fragmentos de texto.")
    
    print("Generando vectores con Google Gemini...")
    embeddings = GoogleGenerativeAIEmbeddings(model="models/text-embedding-004")
    
    # Asegurarse de que el directorio de la DB existe
    if not os.path.exists(DB_DIR):
        os.makedirs(DB_DIR)

    Chroma.from_documents(
        documents=chunks,
        embedding=embeddings,
        persist_directory=DB_DIR
    )
    print(f" Exito! Base de datos guardada en: {DB_DIR}")


def build_vectorad_db():
    return build_vector_db()

if __name__ == "__main__":
    build_vector_db()