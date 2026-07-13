"""
Cohen's Kappa analysis: NRC lexicon scoring vs Linguistic expert review
Ambiguous motivational quotes labelled with a dominant emotion (n = 811).

NRC label      = 'Emotion' column (NRC dominant emotion, mapped to 4-class scheme)
Expert label   = NRC label where expert Agreed;
                 'Suggested Emotion' where expert Disagreed;
                 'happy' for the 2 resolved rows with blank suggestion.
"""

import pandas as pd
from sklearn.metrics import cohen_kappa_score, confusion_matrix

FILE = "expertreview ver_Motivational Quotes Dataset.xlsx"
SHEET = "Labelled with Emotion"
LABELS = ["happy", "sad", "angry", "surprise"]  # fixed 4-class order

df = pd.read_excel(FILE, sheet_name=SHEET)

# --- Build the two parallel label columns ---
df["nrc_label"] = df["Emotion"].str.strip().str.lower()

def expert_label(row):
    agree = str(row["Expert Agreemment"]).strip().lower()
    if agree == "agree":
        return row["nrc_label"]
    # Disagree -> use suggested emotion; blank suggestion -> resolved as 'happy'
    sugg = row["Suggested Emotion"]
    if pd.isna(sugg) or str(sugg).strip() == "":
        return "happy"
    return str(sugg).strip().lower()

df["expert_label"] = df.apply(expert_label, axis=1)

n = len(df)

# --- 1. Cohen's Kappa ---
kappa = cohen_kappa_score(df["nrc_label"], df["expert_label"], labels=LABELS)

def landis_koch(k):
    if k < 0.00:  return "Poor (< 0.00)"
    if k <= 0.20: return "Slight (0.00-0.20)"
    if k <= 0.40: return "Fair (0.21-0.40)"
    if k <= 0.60: return "Moderate (0.41-0.60)"
    if k <= 0.80: return "Substantial (0.61-0.80)"
    return "Almost perfect (0.81-1.00)"

# --- 2. Observed agreement (raw %) for context ---
observed_agreement = (df["nrc_label"] == df["expert_label"]).mean()

# --- 3. Per-class distribution (both label sets) ---
nrc_counts = df["nrc_label"].value_counts().reindex(LABELS, fill_value=0)
exp_counts = df["expert_label"].value_counts().reindex(LABELS, fill_value=0)

# --- 4. Confusion matrix (rows = NRC, cols = Expert) ---
cm = confusion_matrix(df["nrc_label"], df["expert_label"], labels=LABELS)
cm_df = pd.DataFrame(cm, index=[f"NRC_{l}" for l in LABELS],
                         columns=[f"Exp_{l}" for l in LABELS])

# ---------- OUTPUT ----------
print("=" * 60)
print("COHEN'S KAPPA: NRC SCORING vs EXPERT REVIEW")
print("=" * 60)
print(f"Ambiguous quotes analysed (n) : {n}")
print(f"Emotion classes               : {LABELS}")
print()
print(f"Observed (raw) agreement      : {observed_agreement:.4f}  ({observed_agreement*100:.2f}%)")
print(f"Cohen's Kappa (k)             : {kappa:.4f}")
print(f"Landis & Koch interpretation  : {landis_koch(kappa)}")
print()
print("-" * 60)
print("Label distribution (NRC vs Expert)")
print("-" * 60)
dist = pd.DataFrame({"NRC": nrc_counts, "Expert": exp_counts})
dist["Change"] = dist["Expert"] - dist["NRC"]
print(dist.to_string())
print()
print("-" * 60)
print("Confusion matrix (rows = NRC label, cols = Expert label)")
print("-" * 60)
print(cm_df.to_string())
print()
# Agreement breakdown
agree_n = (df["nrc_label"] == df["expert_label"]).sum()
disagree_n = n - agree_n
print(f"On-diagonal (NRC = Expert)    : {agree_n}")
print(f"Off-diagonal (relabelled)     : {disagree_n}")