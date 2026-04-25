print("🔥 STARTING API...")
from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
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


@app.get("/")
def root():
    return {"message": "API is running"}   # health check


@app.post("/analyze")
async def analyze(image: UploadFile = File(...)):
    try:
        file_path = os.path.join(UPLOAD_FOLDER, image.filename)

        with open(file_path, "wb") as buffer:
            buffer.write(await image.read())

        emotion = detect_emotion(file_path)
        quotes = recommend_quotes(emotion)

        return {
            "emotion": emotion,
            "quotes": quotes
        }

    except Exception as e:
        return {"error": str(e)}
    
# your existing code stays the same...

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("api_server:app", host="0.0.0.0", port=8080)