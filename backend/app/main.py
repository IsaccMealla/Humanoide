from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.database import supabase
from app.routers import agent

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(agent.router, prefix="/agent", tags=["agent"])

@app.get("/")
def root():
    return {"message": "Backend running"}

@app.get("/test-supabase")
def test_supabase():
    response = supabase.table("test").select("*").execute()
    return response.data