from PIL import Image
import time
import os
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

client = None


def get_client():
    global client

    if client is None:
        API_KEY = os.getenv("GEMINI_API_KEY")

        if not API_KEY:
            raise ValueError("GEMINI_API_KEY not found")

        genai.configure(api_key=API_KEY)
        client = genai.GenerativeModel("gemini-2.5-flash")

    return client


def _map_emotion_result(result: str) -> dict:
    normalized = result.strip().lower()

    if "happy" in normalized:
        return {"emotion": "happy", "confidence": 0.92}
    if "sad" in normalized:
        return {"emotion": "sad", "confidence": 0.88}
    if "angry" in normalized:
        return {"emotion": "angry", "confidence": 0.86}
    if "surprise" in normalized:
        return {"emotion": "surprise", "confidence": 0.90}

    return {"emotion": "no emotion detected", "confidence": 0.0}


def detect_emotion(image_path):
    return detect_emotion_detailed(image_path)["emotion"]


def detect_emotion_detailed(image_path):
    img = Image.open(image_path)

    prompt = """
You are a facial emotion recognition system.

Analyze the human facial expression.

Return ONLY one of:
happy, sad, angry, surprise

If you are NOT confident or no clear face/emotion is visible:
return exactly: no emotion
"""

    client = get_client()

    for attempt in range(3):
        try:
            response = client.generate_content([prompt, img])
            result = response.text.strip().lower()
            return _map_emotion_result(result)

        except Exception as e:
            print(f"Retry {attempt+1}:", e)
            time.sleep(2)

    return {"emotion": "no emotion detected", "confidence": 0.0}