from fastapi import FastAPI
from app.core.database import supabase

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Backend running"}

@app.get("/test-supabase")
def test_supabase():
    response = supabase.table("test").select("*").execute()
    return response.data