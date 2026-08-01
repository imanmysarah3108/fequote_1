"""Offline evaluation of the CBF quote recommender: Precision@k, Recall@k, nDCG@k.

Workflow
--------
1. Run `python rank_quotes.py` to print the deterministic ranked top-10 per
   emotion, and grade each of the 10 quotes 0/1/2 by hand.
2. Paste those grades into the GRADES dict below (order = the 1..10 order the
   ranking was printed in).
3. Run `python evaluation.py`.

Evaluation design (two lenses)
------------------------------
The recommender is a two-stage system: it deterministically ranks the
emotion-filtered quotes by SBERT cosine similarity, then the app displays a
selection for variety. We DECOUPLE the two: metrics are computed on the model's
DETERMINISTIC ranked output (top-k). The live app's random selection over the
top candidates is a presentation-layer variety feature, outside the scope of
model-performance evaluation.

Two relevance lenses are reported, and they use DIFFERENT reference sets ON
PURPOSE:

- QUALITY  -> Precision@k and nDCG@k. Judged against fine-grained MANUAL grades
             (0/1/2) on the displayed top-k. Answers: "are the shown quotes
             relevant and well-ordered?"
             * Precision@k = relevant (grade > 0) in the top-k / k
             * nDCG@k      = DCG of the top-k grades / DCG of their ideal order

- COVERAGE -> Recall@k. Judged against a COARSE emotion-label reference set: a
             quote is "relevant" iff its emotion label equals the query emotion.
             The relevant set is therefore EVERY quote in the corpus carrying
             that emotion (CORPUS_COUNTS below). Answers: "of all quotes for this
             emotion, what fraction did the top-k surface?"
             * Recall@k = (relevant quotes in top-k) / (all quotes of that
               emotion in the corpus)
             Because the recommender pre-filters by emotion, all k retrieved
             quotes carry the matching label, so the numerator is k and
             Recall@k = k / N_emotion. This is bounded near zero at small k over
             a large relevant pool by construction, and is reported as a
             coverage indicator, not a ranking-quality measure.
"""

import os
import numpy as np
import pandas as pd

EMOTIONS = ["happy", "sad", "angry", "surprise"]

# Number of displayed/ranked quotes the metrics are computed over.
K = 5

# ====== HAND GRADES: 10 per emotion, in the 1..10 order from rank_quotes.py ======
# Relevance grades: 0 = not relevant, 1 = somewhat relevant, 2 = relevant.
# QUALITY lens only (Precision@k / nDCG@k).
GRADES = {
    "happy":    [2, 2, 1, 2, 2, 2, 2, 1, 2, 1],
    "sad":      [2, 2, 2, 2, 2, 2, 1, 2, 2, 0],
    "angry":    [2, 2, 2, 2, 2, 2, 1, 0, 2, 2],
    "surprise": [2, 1, 0, 2, 2, 0, 2, 0, 1, 0],
}


def load_corpus_counts():
    """Total quotes per emotion in the dataset = COVERAGE recall denominator.

    Read from the dataset so the number always matches the live corpus. Falls
    back to the known counts if the file cannot be read.
    """
    csv_path = os.path.join(os.path.dirname(__file__),
                            "dataset", "emotion_quotes.csv")
    try:
        data = pd.read_csv(csv_path)
        counts = data["emotion"].value_counts().to_dict()
        return {e: int(counts.get(e, 0)) for e in EMOTIONS}
    except Exception as exc:  # pragma: no cover - defensive fallback
        print(f"(Could not read {csv_path}: {exc}; using known counts.)")
        return {"happy": 1463, "sad": 459, "angry": 197, "surprise": 73}


def deterministic_top_k(pool, k=K):
    """The model's ranked output: ranks 1..k, no randomization (decoupled)."""
    return pool[:k]


def precision_at_k(topk):
    """QUALITY: relevant (grade > 0) in the top-k, divided by k."""
    return sum(1 for g in topk if g > 0) / len(topk)


def recall_at_k(topk, corpus_relevant_total):
    """COVERAGE: relevant retrieved / all relevant of that emotion in the corpus.

    All retrieved quotes are emotion-matched (the recommender pre-filters by
    emotion), so the numerator is simply the number retrieved (= k).
    """
    if corpus_relevant_total == 0:
        return 0.0
    return len(topk) / corpus_relevant_total


def dcg(grades):
    """Discounted cumulative gain over graded relevance in the given order."""
    return sum(g / np.log2(i + 2) for i, g in enumerate(grades))


def ndcg_at_k(topk):
    """QUALITY: DCG of the top-k grades / DCG of the ideal ordering of those k."""
    ideal = dcg(sorted(topk, reverse=True))
    if ideal == 0:
        return 0.0
    return dcg(topk) / ideal


def main():
    corpus_counts = load_corpus_counts()

    print("Deterministic top-k ranking (randomization decoupled to UI layer)")
    print(f"k = {K}")
    print("=" * 64)

    precisions, recalls, ndcgs = [], [], []

    for emotion in EMOTIONS:
        pool = GRADES[emotion]
        topk = deterministic_top_k(pool)
        n_corpus = corpus_counts[emotion]

        p = precision_at_k(topk)
        r = recall_at_k(topk, n_corpus)
        n = ndcg_at_k(topk)

        precisions.append(p)
        recalls.append(r)
        ndcgs.append(n)

        print(f"\n{emotion.upper()}")
        print(f"  top-{K} grades:        {topk}")
        print(f"  Precision@{K} (quality): {p:.3f}")
        print(f"  nDCG@{K}      (quality): {n:.3f}")
        print(f"  Recall@{K}    (coverage): {r:.4f}  "
              f"= {K}/{n_corpus} relevant quotes for '{emotion}'")

    print("\n" + "=" * 64)
    print("MEAN ACROSS 4 EMOTIONS")
    print(f"  Precision@{K} (quality):  {np.mean(precisions):.3f}")
    print(f"  nDCG@{K}      (quality):  {np.mean(ndcgs):.3f}")
    print(f"  Recall@{K}    (coverage): {np.mean(recalls):.4f}")


if __name__ == "__main__":
    main()
