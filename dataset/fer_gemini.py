from PIL import Image
import time
import os
from dotenv import load_dotenv
import google.generativeai as genai

load_dotenv()

API_KEY = os.getenv("GEMINI_API_KEY")

genai.configure(api_key=API_KEY)

client = genai.GenerativeModel("gemini-2.5-flash")


def detect_emotion(image_path):

    img = Image.open(image_path)

    prompt = """
You are a facial emotion recognition system.

Analyze the human facial expression.

Return ONLY one of:
happy, sad, angry, surprise

If you are NOT confident or no clear face/emotion is visible:
return exactly: no emotion

Rules:
- Only ONE answer
- No explanation
"""

    for attempt in range(3):
        try:
            response = client.generate_content([prompt, img])
            result = response.text.strip().lower()

            # Normalize result
            if "happy" in result:
                return "happy"
            elif "sad" in result:
                return "sad"
            elif "angry" in result:
                return "angry"
            elif "surprise" in result:
                return "surprise"
            elif "no emotion" in result:
                return "no emotion detected, try again"
            else:
                return "no emotion detected, try again"

        except Exception as e:
            print(f"Retry {attempt+1}:", e)
            time.sleep(2)

    return "no emotion detected, try again"


# Test
if __name__ == "__main__":
    image_path = "dataset/test_images/angry.jpg"

    result = detect_emotion(image_path)

    print("\nDetected Emotion:", result)