from fastapi import FastAPI
from datetime import datetime

app = FastAPI()

@app.get("/")
def read_root():
    return {
        "message": "Hello from Python FastAPI!",
        "time": datetime.utcnow().isoformat() + "Z"
    }
