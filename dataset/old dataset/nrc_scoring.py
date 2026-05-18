import pandas as pd
import re
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
import nltk

# =========================
# DOWNLOAD NLTK DATA
# =========================

nltk.download('punkt')
nltk.download('stopwords')

# =========================
# LOAD CLEANED DATASET
# =========================

# Make sure clean_quotes.csv contains:
# quote, author

df = pd.read_csv(
    "clean_quotes.csv",
    encoding="utf-8"
)

print("Dataset loaded:", len(df))

# =========================
# LOAD NRC LEXICON
# =========================

nrc = pd.read_csv(
    "NRC-Emotion-Lexicon-Wordlevel-v0.92.txt",
    sep="\t",
    names=["word", "emotion", "association"]
)

# Keep only valid emotion associations
nrc = nrc[nrc["association"] == 1]

print("NRC lexicon loaded")

# =========================
# BUILD EMOTION DICTIONARY
# =========================

emotion_dict = {}

for _, row in nrc.iterrows():

    word = row["word"]
    emotion = row["emotion"]

    if word not in emotion_dict:
        emotion_dict[word] = []

    emotion_dict[word].append(emotion)

# =========================
# STOPWORDS
# =========================

stop_words = set(stopwords.words('english'))

# =========================
# EMOTION SCORING FUNCTION
# =========================

def get_emotion_scores(quote):

    # Lowercase
    clean_quote = str(quote).lower()

    # Remove punctuation
    clean_quote = re.sub(r'[^\w\s]', '', clean_quote)

    # Tokenize
    tokens = word_tokenize(clean_quote)

    # Remove stopwords
    tokens = [
        word for word in tokens
        if word not in stop_words
    ]

    # Empty token handling
    if len(tokens) == 0:
        return {
            "joy": 0,
            "sadness": 0,
            "anger": 0,
            "surprise": 0
        }

    # Initialize scores
    scores = {
        "joy": 0,
        "sadness": 0,
        "anger": 0,
        "surprise": 0
    }

    # NRC matching
    for word in tokens:

        if word in emotion_dict:

            for emotion in emotion_dict[word]:

                if emotion in scores:
                    scores[emotion] += 1

    return scores

# =========================
# STORE RESULTS
# =========================

results = []

# =========================
# PROCESS EACH QUOTE
# =========================

for _, row in df.iterrows():

    quote = row["quote"]
    author = row["author"]

    # Get emotion scores
    scores = get_emotion_scores(quote)

    # Total emotion score
    total = sum(scores.values())

    # =========================
    # HANDLE NO EMOTION CASE
    # =========================

    if total == 0:

        dominant = "unknown"
        confidence = 0
        ambiguous = True

    else:

        # Dominant emotion
        dominant = max(scores, key=scores.get)

        # Confidence score
        max_score = scores[dominant]
        confidence = max_score / total

        # Ambiguity detection
        if confidence < 0.5:
            ambiguous = True
        else:
            ambiguous = False

    # =========================
    # MAP TO FINAL EMOTIONS
    # =========================

    mapping = {
        "joy": "happy",
        "sadness": "sad",
        "anger": "angry",
        "surprise": "surprise"
    }

    emotion = mapping.get(dominant, "unknown")

    # =========================
    # SAVE RESULTS
    # =========================

    results.append({

        "quote": quote,
        "author": author,

        "joy": scores["joy"],
        "sadness": scores["sadness"],
        "anger": scores["anger"],
        "surprise": scores["surprise"],

        "dominant": dominant,
        "confidence": round(confidence, 2),
        "ambiguous": ambiguous,

        "emotion": emotion
    })

# =========================
# CONVERT TO DATAFRAME
# =========================

final_df = pd.DataFrame(results)

# =========================
# OPTIONAL:
# REMOVE UNKNOWN EMOTIONS
# =========================

# Uncomment if you want to remove quotes
# with no detected emotion

# final_df = final_df[
#     final_df["emotion"] != "unknown"
# ]

# =========================
# SAVE OUTPUT
# =========================

final_df.to_csv(
    "nrc_scored_quotes.csv",
    index=False,
    encoding="utf-8-sig"
)

# =========================
# SUMMARY
# =========================

print("\n✅ NRC scoring completed!")

print("Total quotes:",
      len(final_df))

print("Ambiguous quotes:",
      final_df["ambiguous"].sum())

print("Unknown emotion quotes:",
      (final_df["emotion"] == "unknown").sum())

print("\nPreview:")
print(final_df.head())