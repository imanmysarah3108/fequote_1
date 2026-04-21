import pandas as pd
from nltk.tokenize import word_tokenize

# Load cleaned dataset (make sure this file has ALL quotes)
df = pd.read_csv("clean_quotes.csv")

# Load NRC lexicon
nrc = pd.read_csv(
    "NRC-Emotion-Lexicon-Wordlevel-v0.92.txt",
    sep="\t",
    names=["word", "emotion", "association"]
)

# Keep only valid associations
nrc = nrc[nrc["association"] == 1]

# Build emotion dictionary
emotion_dict = {}

for _, row in nrc.iterrows():
    word = row["word"]
    emotion = row["emotion"]

    if word not in emotion_dict:
        emotion_dict[word] = []

    emotion_dict[word].append(emotion)


# Function to calculate NRC scores
def get_emotion_scores(quote):
    tokens = word_tokenize(str(quote).lower())

    scores = {
        "joy": 0,
        "sadness": 0,
        "anger": 0,
        "surprise": 0
    }

    for word in tokens:
        if word in emotion_dict:
            for emotion in emotion_dict[word]:
                if emotion in scores:
                    scores[emotion] += 1

    return scores


# Store results
results = []

for quote in df["quote"]:

    scores = get_emotion_scores(quote)

    # Total score
    total = sum(scores.values())

    # Handle no-emotion case
    if total == 0:
        dominant = "joy"   # default fallback
        ambiguous = True
    else:
        # Get dominant emotion
        dominant = max(scores, key=scores.get)

        # Confidence calculation
        max_score = scores[dominant]
        confidence = max_score / total

        # Ambiguity detection
        if confidence < 0.5:
            ambiguous = True
        else:
            ambiguous = False

    # Map to your 4 categories
    mapping = {
        "joy": "happy",
        "sadness": "sad",
        "anger": "angry",
        "surprise": "surprise"
    }

    emotion = mapping.get(dominant, "happy")

    results.append({
        "quote": quote,
        "joy": scores["joy"],
        "sadness": scores["sadness"],
        "anger": scores["anger"],
        "surprise": scores["surprise"],
        "dominant": dominant,
        "ambiguous": ambiguous,
        "emotion": emotion
    })


# Convert to DataFrame
final_df = pd.DataFrame(results)

# Save output
final_df.to_csv("nrc_scored_quotes.csv", index=False)

print("✅ NRC scoring completed!")
print("Total quotes:", len(final_df))
print("Ambiguous count:", final_df["ambiguous"].sum())
print(final_df.head())