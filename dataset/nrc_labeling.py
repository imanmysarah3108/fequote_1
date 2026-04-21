import pandas as pd
import nltk
from nltk.tokenize import word_tokenize

# Load dataset
quotes = pd.read_csv("clean_quotes.csv")

# Load NRC lexicon
nrc = pd.read_csv(
    "NRC-Emotion-Lexicon-Wordlevel-v0.92.txt",
    sep="\t",
    names=["word","emotion","association"]
)

# Keep only words with association = 1
nrc = nrc[nrc["association"] == 1]

# Create dictionary
emotion_dict = {}
for _, row in nrc.iterrows():
    word = row["word"]
    emotion = row["emotion"]

    if word not in emotion_dict:
        emotion_dict[word] = []

    emotion_dict[word].append(emotion)

# Function to detect emotion
def detect_emotion(quote):

    tokens = word_tokenize(str(quote).lower())

    emotion_count = {
        "joy":0,
        "sadness":0,
        "anger":0,
        "surprise":0
    }

    for word in tokens:
        if word in emotion_dict:
            for emotion in emotion_dict[word]:
                if emotion in emotion_count:
                    emotion_count[emotion] += 1

    if sum(emotion_count.values()) == 0:
        return "happy"

    dominant = max(emotion_count, key=emotion_count.get)

    # Map NRC emotions → system emotions
    mapping = {
        "joy":"happy",
        "sadness":"sad",
        "anger":"angry",
        "surprise":"surprise"
    }

    return mapping.get(dominant, "happy")

# Apply labeling
quotes["emotion"] = quotes["quote"].apply(detect_emotion)

# Keep final dataset
quotes = quotes[["quote","emotion"]]

quotes.to_csv("emotion_quotes.csv", index=False)

print("Emotion labeling completed")
print(quotes.head())