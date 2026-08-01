"""
Rebuild dataset/emotion_quotes.csv (the final 4-class quote dataset used by the
CBF recommender) from its two upstream sources:

    dataset/nrc_scored_quotes_v2.csv              (output of dataset/nrc_scoring_v2.py)
    expertreview ver_Motivational Quotes Dataset.xlsx  (linguistic expert review)

The committed emotion_quotes.csv was originally assembled by hand in Microsoft
Excel. This script reproduces that manual consolidation in code so the pipeline
is fully reproducible, and verifies the rebuild against the committed file.

CONSOLIDATION RULE (as originally performed in Excel)
-----------------------------------------------------
Starting from the 2,817 NRC-scored quotes, partition on the columns produced by
nrc_scoring_v2.py:

  1. emotion == 'unknown'  (no NRC lexicon match; total score 0)   -> DROPPED
  2. ambiguous == False    (confidence >= 0.35)                    -> keep NRC label
  3. ambiguous == True and emotion != 'unknown' (confidence < 0.35)-> EXPERT REVIEW
         expert Agreed    -> keep the NRC label
         expert Disagreed -> use the expert's 'Suggested Emotion'

Row order of the final file is [group 2 block] followed by [group 3 block],
matching how the two Excel sheets were concatenated.

The author field is also normalised: the Goodreads source stores many authors
with a trailing comma ("Eleanor Roosevelt,"), which survives prepare_dataset.py
and nrc_scoring_v2.py. The committed emotion_quotes.csv has these stripped, so
that normalisation happened during the manual Excel merge and is reproduced here
(it affects 1,083 of the 2,192 final rows).

Usage
-----
    python build_final_dataset.py            # verify, then write if it matches
    python build_final_dataset.py --check    # verify only, never write
    python build_final_dataset.py --force    # write even if verification fails

Requires: pandas, openpyxl.
Exit code 0 = rebuild matches the committed file; 1 = mismatch.
"""

import argparse
import sys
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parent

SCORED_CSV = ROOT / "dataset" / "nrc_scored_quotes_v2.csv"
REVIEW_XLSX = ROOT / "expertreview ver_Motivational Quotes Dataset.xlsx"
REVIEW_SHEET = "Labelled with Emotion"
FINAL_CSV = ROOT / "dataset" / "emotion_quotes.csv"

FINAL_COLUMNS = ["quote", "author", "emotion"]
CLASSES = ["happy", "sad", "angry", "surprise"]

# Expected stage counts, from the committed data. Asserted so that a silently
# changed upstream file fails loudly instead of producing a wrong dataset.
EXPECTED_SCORED = 2817
EXPECTED_UNKNOWN = 625
EXPECTED_CONFIDENT = 1381
EXPECTED_AMBIGUOUS = 811
EXPECTED_FINAL = 2192


def load_scored():
    df = pd.read_csv(SCORED_CSV, encoding="utf-8-sig")
    if len(df) != EXPECTED_SCORED:
        raise ValueError(
            f"{SCORED_CSV.name}: expected {EXPECTED_SCORED} rows, found {len(df)}. "
            "Re-run dataset/nrc_scoring_v2.py or update EXPECTED_SCORED."
        )
    if df["quote"].duplicated().any():
        raise ValueError("Duplicate quote text in the scored CSV; cannot join on quote.")
    return df


def load_expert_labels(ambiguous_quotes):
    """Map quote text -> expert label for the 811 ambiguous quotes."""
    xl = pd.read_excel(REVIEW_XLSX, sheet_name=REVIEW_SHEET)

    xl["quote"] = xl["Quote"].astype(str)
    xl["nrc_label"] = xl["Emotion"].astype(str).str.strip().str.lower()

    # The review sheet must cover exactly the ambiguous set - no more, no less.
    reviewed = set(xl["quote"])
    expected = set(ambiguous_quotes)
    if reviewed != expected:
        raise ValueError(
            f"Review sheet does not match the ambiguous set: "
            f"{len(expected - reviewed)} ambiguous quote(s) missing from the workbook, "
            f"{len(reviewed - expected)} workbook quote(s) not in the ambiguous set."
        )

    def expert_label(row):
        agree = str(row["Expert Agreemment"]).strip().lower()
        if agree == "agree":
            return row["nrc_label"]
        if agree != "disagree":
            raise ValueError(
                f"Row {row.name}: 'Expert Agreemment' is {agree!r}, "
                "expected 'Agree' or 'Disagree'."
            )
        suggested = row["Suggested Emotion"]
        if pd.isna(suggested) or str(suggested).strip() == "":
            raise ValueError(
                f"Row {row.name}: expert Disagreed but 'Suggested Emotion' is blank."
            )
        return str(suggested).strip().lower()

    xl["expert_label"] = xl.apply(expert_label, axis=1)

    bad = sorted(set(xl["expert_label"]) - set(CLASSES))
    if bad:
        raise ValueError(f"Expert labels outside the 4-class scheme: {bad}")

    agreed = int((xl["expert_label"] == xl["nrc_label"]).sum())
    relabelled = len(xl) - agreed
    return dict(zip(xl["quote"], xl["expert_label"])), agreed, relabelled


def build():
    scored = load_scored()

    unknown = scored[scored["emotion"] == "unknown"]
    known = scored[scored["emotion"] != "unknown"]

    confident = known[~known["ambiguous"].astype(bool)]
    ambiguous = known[known["ambiguous"].astype(bool)]

    for name, got, want in [
        ("unknown (dropped)", len(unknown), EXPECTED_UNKNOWN),
        ("confident", len(confident), EXPECTED_CONFIDENT),
        ("ambiguous", len(ambiguous), EXPECTED_AMBIGUOUS),
    ]:
        if got != want:
            raise ValueError(f"{name}: expected {want} rows, found {got}.")

    expert, agreed, relabelled = load_expert_labels(ambiguous["quote"])

    # Group 2: confident quotes keep their NRC label untouched.
    part_confident = confident[FINAL_COLUMNS].copy()

    # Group 3: ambiguous quotes take the expert-adjudicated label.
    part_ambiguous = ambiguous[FINAL_COLUMNS].copy()
    part_ambiguous["emotion"] = part_ambiguous["quote"].map(expert)

    final = pd.concat([part_confident, part_ambiguous], ignore_index=True)

    # The Goodreads source leaves a trailing comma on many author names
    # ("Eleanor Roosevelt,"). Strip it, as the Excel merge did.
    final["author"] = final["author"].astype(str).str.strip().str.rstrip(",").str.strip()

    stats = {
        "scored": len(scored),
        "unknown": len(unknown),
        "confident": len(confident),
        "ambiguous": len(ambiguous),
        "agreed": agreed,
        "relabelled": relabelled,
        "final": len(final),
    }
    return final, stats


def verify(final):
    """Compare the rebuild against the committed file. Returns True if identical."""
    if not FINAL_CSV.exists():
        print(f"  ! {FINAL_CSV.name} does not exist - nothing to verify against.")
        return False

    committed = pd.read_csv(FINAL_CSV)

    if len(committed) != len(final):
        print(f"  x row count: committed {len(committed)}, rebuilt {len(final)}")
        return False

    if list(committed.columns) != FINAL_COLUMNS:
        print(f"  x columns: committed {list(committed.columns)}, expected {FINAL_COLUMNS}")
        return False

    same = committed.reset_index(drop=True).equals(final.reset_index(drop=True))
    if not same:
        merged = committed.merge(
            final, on="quote", how="outer", suffixes=("_committed", "_rebuilt")
        )
        diff = merged[merged["emotion_committed"] != merged["emotion_rebuilt"]]
        print(f"  x contents differ ({len(diff)} row(s) with a differing label)")
        for _, r in diff.head(10).iterrows():
            print(
                f"      {str(r['quote'])[:55]!r}: "
                f"committed={r['emotion_committed']!r} rebuilt={r['emotion_rebuilt']!r}"
            )
        return False

    print(f"  + matches the committed {FINAL_CSV.name} exactly "
          f"({len(final)} rows, same order, same labels)")
    return True


def write(final):
    final.to_csv(FINAL_CSV, index=False, encoding="utf-8", lineterminator="\n")
    print(f"  + wrote {FINAL_CSV.relative_to(ROOT)} ({len(final)} rows)")


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    ap.add_argument("--check", action="store_true", help="verify only, never write")
    ap.add_argument("--force", action="store_true", help="write even if verification fails")
    args = ap.parse_args()

    final, s = build()

    print("=" * 62)
    print("REBUILD: emotion_quotes.csv")
    print("=" * 62)
    print(f"  NRC-scored quotes                  : {s['scored']}")
    print(f"  - dropped (unknown / no NRC match) : {s['unknown']}")
    print(f"  = eligible                         : {s['scored'] - s['unknown']}")
    print()
    print(f"  Confident (NRC label kept)         : {s['confident']}")
    print(f"  Ambiguous (expert-reviewed)        : {s['ambiguous']}")
    print(f"      expert agreed  (label kept)    : {s['agreed']}")
    print(f"      expert disagreed (relabelled)  : {s['relabelled']}")
    print()
    print(f"  FINAL                              : {s['final']}")
    if s["final"] != EXPECTED_FINAL:
        print(f"  ! expected {EXPECTED_FINAL}")
    print()
    print("  Class distribution:")
    counts = final["emotion"].value_counts().reindex(CLASSES, fill_value=0)
    for cls, n in counts.items():
        print(f"      {cls:<9}: {n:>5}  ({n / len(final) * 100:.1f}%)")
    print()
    print("Verification against committed file:")
    ok = verify(final)
    print()

    if args.check:
        return 0 if ok else 1

    if ok or args.force:
        write(final)
        return 0

    print("Refusing to overwrite: rebuild does not match the committed file.")
    print("Re-run with --force if the rebuild is intentionally the new truth.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
