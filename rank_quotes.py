"""Print the recommender's deterministic top-10 ranking per emotion for grading.

Run from the repo root:  python rank_quotes.py

For each emotion this prints the top 10 quotes by cosine similarity, in ranked
order, with random sampling disabled (deterministic=True). Grade each numbered
line 0/1/2 by hand, then paste the grades — in the same 1..10 order — into the
GRADES dict in evaluation.py.
"""

from recommender_system.quote_recommender import recommend_quotes

EMOTIONS = ["happy", "sad", "angry", "surprise"]


def main():
    print("Deterministic top-10 ranking per emotion (random sampling disabled).")
    print("Grade each line 0/1/2 and paste into GRADES in evaluation.py "
          "(same 1..10 order).\n")

    for emotion in EMOTIONS:
        pool = recommend_quotes(emotion, top_n=10, deterministic=True)
        print("=" * 70)
        print(f"EMOTION: {emotion}  ({len(pool)} quotes)")
        print("=" * 70)
        for n, item in enumerate(pool, start=1):
            quote = item["quote"]
            author = item["author"]
            attribution = f"  - {author}" if author else ""
            print(f"  {n:>2}. {quote}{attribution}")
        print()


if __name__ == "__main__":
    main()
