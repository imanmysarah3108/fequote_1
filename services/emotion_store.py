import json
import os
from datetime import datetime
from typing import Any, Dict, List

STORE_PATH = os.path.join("data", "emotion_logs.json")


def _ensure_store() -> Dict[str, List[Dict[str, Any]]]:
    os.makedirs(os.path.dirname(STORE_PATH), exist_ok=True)
    if not os.path.exists(STORE_PATH):
        return {}

    with open(STORE_PATH, "r", encoding="utf-8") as file:
        return json.load(file)


def _write_store(data: Dict[str, List[Dict[str, Any]]]) -> None:
    os.makedirs(os.path.dirname(STORE_PATH), exist_ok=True)
    with open(STORE_PATH, "w", encoding="utf-8") as file:
        json.dump(data, file, indent=2)


def log_emotion(device_id: str, emotion: str, confidence: float) -> Dict[str, Any]:
    store = _ensure_store()
    records = store.get(device_id, [])

    record = {
        "emotion": emotion.lower(),
        "confidence": confidence,
        "timestamp": datetime.now().isoformat(),
    }
    records.append(record)
    store[device_id] = records
    _write_store(store)
    return record


def get_records(device_id: str) -> List[Dict[str, Any]]:
    store = _ensure_store()
    return store.get(device_id, [])
