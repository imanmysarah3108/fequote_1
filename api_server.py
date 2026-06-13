print("🔥 STARTING API...")
from fastapi import FastAPI, File, Form, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import os
from recommender_system.main_pipeline import recommend_quotes
from dataset.fer_gemini import detect_emotion_detailed
from dataset.gemini_rewrite import rewrite_quote
from services.emotion_store import get_records, log_emotion
from services.mood_analytics import build_weekly_dashboard

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_FOLDER = "temp"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


class RewriteRequest(BaseModel):
    quote: str = Field(min_length=1)
    context: str = Field(min_length=1)


@app.get("/")
def root():
    return {"message": "API is running"}


@app.post("/analyze")
async def analyze(
    image: UploadFile = File(...),
    device_id: str | None = Form(default=None),
):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, image.filename)

        with open(file_path, "wb") as buffer:
            buffer.write(await image.read())

        detection = detect_emotion_detailed(file_path)
        emotion = detection["emotion"]
        confidence = detection["confidence"]
        quotes = recommend_quotes(emotion)

        if device_id and emotion != "no emotion detected":
            log_emotion(device_id, emotion, confidence)

        return {
            "emotion": emotion,
            "confidence": confidence,
            "quotes": quotes,
        }

    except Exception as e:
        return {"error": str(e)}


@app.get("/mood/weekly")
def mood_weekly(device_id: str):
    try:
        records = get_records(device_id)
        dashboard = build_weekly_dashboard(records)
        return dashboard
    except Exception as e:
        return {"error": str(e)}


@app.post("/rewrite")
def rewrite(request: RewriteRequest):
    try:
        rewritten = rewrite_quote(request.quote, request.context)
        return {"rewritten_quote": rewritten}
    except Exception as e:
        return {"error": str(e)}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("api_server:app", host="0.0.0.0", port=8080)
