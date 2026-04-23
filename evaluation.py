import numpy as np

def precision_at_k(scores):
    relevant = [1 if s > 0 else 0 for s in scores]
    return sum(relevant) / len(relevant)

def recall_at_k(scores):
    relevant = [1 if s > 0 else 0 for s in scores]
    total_relevant = len(scores)  # simple assumption
    return sum(relevant) / total_relevant

def dcg(scores):
    return sum([score / np.log2(i + 2) for i, score in enumerate(scores)])

def ndcg(scores):
    ideal = sorted(scores, reverse=True)
    return dcg(scores) / dcg(ideal)

# ====== INPUT YOUR SCORES HERE ======
#Happy Scores: [2,2,1,1,2]
#Sad Scores: [2,2,2,2,0]
#Angry Scores: [1,0,1,2,2]
#Surprise Scores: [2,1,0,1,1]
scores = [2,1,0,1,1]

print("Precision:", precision_at_k(scores))
print("Recall:", recall_at_k(scores))
print("nDCG:", ndcg(scores))