import pandas as pd
from sentence_transformers import SentenceTransformer
import numpy as np

# Load dataset
data = pd.read_csv("../dataset/emotion_quotes.csv")

# Load SBERT model
model = SentenceTransformer('all-MiniLM-L6-v2')

# Convert quotes to list
quotes = data['quote'].tolist()

print("Generating embeddings...")

# Generate embeddings
embeddings = model.encode(quotes)

# Save embeddings
np.save("quote_embeddings.npy", embeddings)

print("✅ Embeddings saved successfully!")