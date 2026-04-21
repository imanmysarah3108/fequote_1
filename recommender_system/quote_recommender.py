import pandas as pd
import numpy as np
import os
import random
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity

# Get current file directory
current_dir = os.path.dirname(__file__)

# Build paths
csv_path = os.path.abspath(os.path.join(current_dir, "../dataset/emotion_quotes.csv"))
embedding_path = os.path.abspath(os.path.join(current_dir, "quote_embeddings.npy"))

# Load dataset
data = pd.read_csv(csv_path)

# Load embeddings
embeddings = np.load(embedding_path)

# Load SBERT model
model = SentenceTransformer('all-MiniLM-L6-v2')


def recommend_quotes(emotion, top_n=5):

    # Filter indices based on emotion
    indices = data[data['emotion'] == emotion].index.tolist()

    if len(indices) == 0:
        return ["No quotes found"]

    filtered_embeddings = embeddings[indices]
    filtered_quotes = data.iloc[indices]['quote'].tolist()

    # Encode query
    query_embedding = model.encode([emotion])

    # Compute similarity
    scores = cosine_similarity(query_embedding, filtered_embeddings)

    ranked_indices = scores[0].argsort()[::-1]

    # Take top 10 ranked quotes
    top_pool_size = min(10, len(filtered_quotes))
    top_pool = [filtered_quotes[i] for i in ranked_indices[:top_pool_size]]

    # Randomly select final quotes
    selected_quotes = random.sample(top_pool, min(top_n, len(top_pool)))

    return selected_quotes