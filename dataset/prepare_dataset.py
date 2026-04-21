import pandas as pd

# Load dataset
df = pd.read_csv("quotes.csv")

print("Original dataset size:", len(df))

# Keep only necessary columns
df = df[['quote', 'tags']]

# Remove duplicates
df = df.drop_duplicates(subset='quote')

# Remove missing quotes
df = df.dropna(subset=['quote'])

# Remove very short quotes (optional but useful)
df = df[df['quote'].str.len() > 20]

print("Clean dataset size:", len(df))

# Save cleaned dataset
df.to_csv("clean_quotes.csv", index=False)

print("Clean dataset saved as clean_quotes.csv")