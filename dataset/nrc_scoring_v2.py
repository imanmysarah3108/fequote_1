import pandas as pd
import re
from nltk.tokenize import word_tokenize
import nltk

# =========================
# DOWNLOAD NLTK DATA
# =========================

nltk.download('punkt')

# =========================
# LOAD CLEANED DATASET
# =========================

# clean_quotes.csv should contain:
# quote, author

df = pd.read_csv(
    "clean_quotes.csv",
    encoding="utf-8"
)

print("Dataset loaded:", len(df))

# =========================
# LOAD NRC LEXICON
# =========================

# NOTE: NRC-Emotion-Lexicon-Wordlevel-v0.92.txt is NOT tracked in git (its
# license asks users to obtain it directly from the NRC site, and the app's
# final dataset is already committed). To re-run this offline scoring script,
# download the lexicon from
# https://saifmohammad.com/WebPages/NRC-Emotion-Lexicon.htm
# and place the .txt file in this dataset/ folder.

nrc = pd.read_csv(
    "NRC-Emotion-Lexicon-Wordlevel-v0.92.txt",
    sep="\t",
    names=["word", "emotion", "association"]
)

# Keep valid associations only
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
# EMOTION SCORING FUNCTION
# =========================

def get_emotion_scores(quote):

    # Convert to lowercase
    clean_quote = str(quote).lower()

    # Remove punctuation
    clean_quote = re.sub(r'[^\w\s]', '', clean_quote)

    # Tokenize
    tokens = word_tokenize(clean_quote)

    # Empty token handling
    if len(tokens) == 0:
        return {
            "joy": 0,
            "sadness": 0,
            "anger": 0,
            "surprise": 0,
            "trust": 0,
            "anticipation": 0
        }

    # Initialize emotion scores
    scores = {
        "joy": 0,
        "sadness": 0,
        "anger": 0,
        "surprise": 0,
        "trust": 0,
        "anticipation": 0
    }

    # NRC word matching
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
    # HANDLE UNKNOWN CASE
    # =========================

    if total == 0:

        dominant = "unknown"
        confidence = 0
        ambiguous = True

    else:

        # Get dominant emotion
        dominant = max(scores, key=scores.get)

        # Confidence calculation
        max_score = scores[dominant]
        confidence = max_score / total

        # Detect ambiguity
        ambiguous = confidence < 0.35

    # =========================
    # MAP NRC TO APP EMOTIONS
    # =========================

    mapping = {

        # Happy-related emotions
        "joy": "happy",
        "trust": "happy",
        "anticipation": "happy",

        # Sad emotion
        "sadness": "sad",

        # Angry emotion
        "anger": "angry",

        # Surprise emotion
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
        "trust": scores["trust"],
        "anticipation": scores["anticipation"],

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
# REMOVE UNKNOWN QUOTES
# =========================

# Uncomment below if you want
# to remove unknown emotion quotes

# final_df = final_df[
#     final_df["emotion"] != "unknown"
# ]

# =========================
# SAVE OUTPUT
# =========================

final_df.to_csv(
    "nrc_scored_quotes_v2.csv",
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