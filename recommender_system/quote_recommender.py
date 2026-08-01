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

data = None
embeddings = None
model = None


def load_resources():
    global data, embeddings, model

    if data is None:
        data = pd.read_csv(csv_path)

    if embeddings is None:
        embeddings = np.load(embedding_path)

    if model is None:
        model = SentenceTransformer('all-MiniLM-L6-v2')


def recommend_quotes(emotion, top_n=5, deterministic=False, seed=None):
    load_resources()
    # Filter indices based on emotion
    indices = data[data['emotion'] == emotion].index.tolist()

    if len(indices) == 0:
        return ["No quotes found"]

    filtered_embeddings = embeddings[indices]
    filtered_rows = data.iloc[indices]
    filtered_quotes = filtered_rows['quote'].tolist()
    filtered_authors = filtered_rows['author'].tolist()

    # Encode query
    query_embedding = model.encode([emotion])

    # Compute similarity
    scores = cosine_similarity(query_embedding, filtered_embeddings)

    ranked_indices = scores[0].argsort()[::-1]

    # Take top 10 ranked quotes (quote + author, ranking/sampling unchanged)
    top_pool_size = min(10, len(filtered_quotes))
    top_pool = [
        {
            "quote": filtered_quotes[i],
            # Coerce missing authors (NaN) to None so the payload stays
            # JSON-serialisable; the client hides the line when it's absent.
            "author": None if pd.isna(filtered_authors[i]) else str(filtered_authors[i]),
        }
        for i in ranked_indices[:top_pool_size]
    ]

    # Deterministic grading path: return the ranked pool as-is, no sampling.
    # Used by the offline evaluation to regenerate a stable ranking to grade.
    if deterministic:
        return top_pool[:top_n]

    # Randomly select final quotes. `seed=None` uses the shared `random` module
    # (identical to the original behaviour for the live app); a supplied seed
    # gives a reproducible sample for evaluation without touching global state.
    rng = random.Random(seed) if seed is not None else random
    selected_quotes = rng.sample(top_pool, min(top_n, len(top_pool)))

    return selected_quotes