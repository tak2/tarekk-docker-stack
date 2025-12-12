from datetime import datetime, timezone

from fastapi import FastAPI

app = FastAPI()
started_at = datetime.now(timezone.utc)


@app.get("/")
def read_root():
    return {
        "message": "Hello from Python FastAPI!",
        "time": datetime.now(timezone.utc).isoformat(),
    }


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "service": "python-fastapi",
        "startedAt": started_at.isoformat(),
        "uptimeSeconds": int((datetime.now(timezone.utc) - started_at).total_seconds()),
    }
