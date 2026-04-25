from PIL import Image
import time
import os
import google.generativeai as genai

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


def detect_emotion(image_path):
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

            if "happy" in result:
                return "happy"
            elif "sad" in result:
                return "sad"
            elif "angry" in result:
                return "angry"
            elif "surprise" in result:
                return "surprise"
            else:
                return "no emotion detected"

        except Exception as e:
            print(f"Retry {attempt+1}:", e)
            time.sleep(2)

    return "no emotion detected"