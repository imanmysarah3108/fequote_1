import pandas as pd
from google import genai

# Initialize client
client = genai.Client(api_key="YOUR_API_KEY_HERE")

# Load dataset
df = pd.read_csv("emotion_quotes.csv")
df=df.head(50)  # Limit to 50 quotes for validation

def validate_emotion(quote):

    prompt = f"""
You are an emotion classification system used in an academic research project.

Classify the emotion of this motivational quote.

Allowed answers ONLY:
happy, sad, angry, surprise

Rules:
- Return ONLY one word
- No explanation
- If unsure → return "surprise"
- If encouraging → return "happy"

Quote:
"{quote}"
"""

    try:
        response = client.models.generate_content(
            model="gemini-1.5-flash-latest",
            contents=prompt
        )

        emotion = response.text.strip().lower().split()[0]

        if emotion not in ["happy","sad","angry","surprise"]:
            emotion = "happy"

        return emotion

    except:
        return "happy"   # fallback if API fails


# Apply validation
df["emotion"] = df["quote"].apply(validate_emotion)

# Save final dataset
df.to_csv("emotion_quotes_validated.csv", index=False)

print("AI validation completed!")
print(df.head())