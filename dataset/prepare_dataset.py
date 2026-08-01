import pandas as pd
import re
from ftfy import fix_text
from langdetect import detect

# =========================
# LOAD DATASET
# =========================

# Read dataset using UTF-8 encoding
df = pd.read_csv("quotes.csv", encoding="utf-8")

print("Original dataset size:", len(df))

# =========================
# KEEP IMPORTANT COLUMNS
# =========================

# Keep only quote and author columns
df = df[['quote', 'author']]

# =========================
# REMOVE DUPLICATES
# =========================

df = df.drop_duplicates(subset='quote')

# =========================
# REMOVE MISSING VALUES
# =========================

df = df.dropna(subset=['quote'])

# =========================
# REMOVE SHORT QUOTES
# =========================

# Keep quotes longer than 20 characters
df = df[df['quote'].str.len() > 20]

# =========================
# FIX BROKEN ENCODING
# =========================

# Fix corrupted apostrophes and unicode issues
df['quote'] = df['quote'].apply(fix_text)

# =========================
# CLEAN WEIRD CHARACTERS
# =========================

def clean_text(text):

    # Remove line breaks
    text = text.replace('\n', ' ').replace('\r', ' ')

    # Remove multiple spaces
    text = re.sub(r'\s+', ' ', text)

    # Remove weird symbols
    text = re.sub(r'[^\w\s.,!?\'"-]', '', text)

    return text.strip()

df['quote'] = df['quote'].apply(clean_text)

# =========================
# REMOVE CORRUPTED QUOTES
# =========================

def valid_quote(text):

    # Count weird symbols ratio
    weird_ratio = sum(
        not c.isalnum() and not c.isspace()
        for c in text
    ) / max(len(text), 1)

    return weird_ratio < 0.3

df = df[df['quote'].apply(valid_quote)]

# =========================
# KEEP ENGLISH QUOTES ONLY
# =========================

def is_english(text):
    try:
        return detect(text) == 'en'
    except:
        return False

df = df[df['quote'].apply(is_english)]

# =========================
# REMOVE EMPTY ROWS AGAIN
# =========================

df = df[df['quote'].str.strip() != ""]

# =========================
# RESET INDEX
# =========================

df = df.reset_index(drop=True)

print("Cleaned dataset size:", len(df))

# =========================
# SAVE CLEAN DATASET
# =========================

df.to_csv(
    "clean_quotes.csv",
    index=False,
    encoding='utf-8-sig'
)

print("Dataset cleaned successfully!")
print("Saved as clean_quotes.csv")