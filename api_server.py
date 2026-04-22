from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
import shutil
import os
from recommender_system.main_pipeline import recommend_quotes
from dataset.fer_gemini import detect_emotion

app = FastAPI()

# Allow Flutter to call API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

UPLOAD_FOLDER = "temp"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)


@app.post("/analyze")
async def analyze(image: UploadFile = File(...)):
    emotion = detect_emotion(image)
    quotes = recommend_quotes(emotion)

    return {
        "emotion": emotion,
        "quotes": quotes
    }