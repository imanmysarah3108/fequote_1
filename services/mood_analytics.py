from datetime import datetime, timedelta
from typing import Any, Dict, List

SUPPORTED_EMOTIONS = ["happy", "sad", "surprise", "angry"]

SUMMARY_TEXT = {
    "Positive": "You had a positive week and maintained a healthy emotional balance.",
    "Balanced": "You had a mix of ups and downs, but you stayed strong and kept going.",
    "Needs Support": "This week appears emotionally challenging. Remember to take time for yourself and seek support when needed.",
    "Emotionally Strained": "You experienced higher emotional stress this week. Taking breaks and practicing self-care may help.",
}


def _parse_timestamp(value: Any) -> datetime:
    if isinstance(value, datetime):
        return value
    text = str(value).replace("Z", "+00:00")
    return datetime.fromisoformat(text)


def get_week_start(reference_date: datetime | None = None) -> datetime:
    reference = reference_date or datetime.now()
    start = reference - timedelta(days=reference.weekday())
    return start.replace(hour=0, minute=0, second=0, microsecond=0)


def get_weekly_emotion_data(
    records: List[Dict[str, Any]],
    reference_date: datetime | None = None,
) -> List[Dict[str, Any]]:
    week_start = get_week_start(reference_date)
    week_end = week_start + timedelta(days=7)

    weekly: List[Dict[str, Any]] = []
    for record in records:
        timestamp = _parse_timestamp(record["timestamp"])
        if week_start <= timestamp < week_end:
            emotion = str(record.get("emotion", "")).lower()
            if emotion in SUPPORTED_EMOTIONS:
                weekly.append(record)
    return weekly


def calculate_emotion_distribution(records: List[Dict[str, Any]]) -> Dict[str, float]:
    counts = {emotion: 0 for emotion in SUPPORTED_EMOTIONS}
    total = 0

    for record in records:
        emotion = str(record.get("emotion", "")).lower()
        if emotion in counts:
            counts[emotion] += 1
            total += 1

    if total == 0:
        return {emotion: 0.0 for emotion in SUPPORTED_EMOTIONS}

    return {
        emotion: round(counts[emotion] / total * 100, 1)
        for emotion in SUPPORTED_EMOTIONS
    }


def generate_weekly_summary(distribution: Dict[str, float]) -> Dict[str, str]:
    happy = distribution.get("happy", 0)
    sad = distribution.get("sad", 0)
    angry = distribution.get("angry", 0)

    if happy > 40:
        title = "Positive"
    elif sad > 40:
        title = "Needs Support"
    elif angry > 40:
        title = "Emotionally Strained"
    else:
        title = "Balanced"

    return {
        "title": title,
        "description": SUMMARY_TEXT[title],
    }


def calculate_statistics(records: List[Dict[str, Any]]) -> Dict[str, Any]:
    if not records:
        return {
            "total_scans": 0,
            "most_frequent_emotion": "—",
            "average_confidence": 0,
            "days_tracked": 0,
        }

    counts = {emotion: 0 for emotion in SUPPORTED_EMOTIONS}
    confidence_sum = 0.0
    days: set[str] = set()

    for record in records:
        emotion = str(record.get("emotion", "")).lower()
        if emotion in counts:
            counts[emotion] += 1
        confidence_sum += float(record.get("confidence", 0))
        timestamp = _parse_timestamp(record["timestamp"])
        days.add(timestamp.date().isoformat())

    most_frequent = max(counts, key=counts.get)
    if counts[most_frequent] == 0:
        most_frequent_label = "—"
    else:
        most_frequent_label = most_frequent.capitalize()

    return {
        "total_scans": len(records),
        "most_frequent_emotion": most_frequent_label,
        "average_confidence": round(confidence_sum / len(records) * 100),
        "days_tracked": len(days),
    }


def build_weekly_dashboard(
    records: List[Dict[str, Any]],
    reference_date: datetime | None = None,
) -> Dict[str, Any]:
    week_start = get_week_start(reference_date)
    week_end = week_start + timedelta(days=6)
    weekly_records = get_weekly_emotion_data(records, reference_date)
    distribution = calculate_emotion_distribution(weekly_records)
    summary = generate_weekly_summary(distribution)
    statistics = calculate_statistics(weekly_records)

    return {
        "week_start": week_start.date().isoformat(),
        "week_end": week_end.date().isoformat(),
        "distribution": distribution,
        "summary": summary,
        "statistics": statistics,
        "records": weekly_records,
    }
