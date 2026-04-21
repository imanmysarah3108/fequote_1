import sys
import os

# Add root project folder to Python path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "..")))

from dataset.fer_gemini import detect_emotion
from recommender_system.quote_recommender import recommend_quotes
def run_pipeline(image_path):

    print("\n📷 Detecting emotion...")

    emotion = detect_emotion(image_path)

    print("Detected Emotion:", emotion)

    # Handle no emotion
    if emotion == "no emotion detected, try again":
        return ["Please try again with a clearer facial expression"]

    print("\n💬 Getting recommendations...")

    quotes = recommend_quotes(emotion)

    return quotes


# Test
if __name__ == "__main__":
    image_path = "dataset/test_images/angry.jpg"

    results = run_pipeline(image_path)

    print("\n✨ Recommended Quotes:\n")
    for i, q in enumerate(results, 1):
        print(f"{i}. {q}")