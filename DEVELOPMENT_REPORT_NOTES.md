# QuoteMyMood / FaceQuote — Development Process Notes

Factual answers drawn directly from the repository source. Every claim cites a
file path and line numbers. Items that do not exist in the repo are stated as
such rather than inferred. Discrepancies, stale comments, and dead code are
flagged inline and summarised at the end.

---

## Q1 — Containerisation and deployment

### Dockerfile (verbatim) — `Dockerfile`
```dockerfile
FROM python:3.11-slim

WORKDIR /app

# 🔥 install system dependencies (IMPORTANT for ML libs)
RUN apt-get update && apt-get install -y \
    build-essential \
    libglib2.0-0 \
    libgl1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=8080

CMD ["uvicorn", "api_server:app", "--host", "0.0.0.0", "--port", "8080"]
```

### Files in the backend build context
The image is built with `COPY . .` from the repo root, minus everything in
`.dockerignore`. After exclusions, the meaningful files copied in are:

| File / dir | Purpose (one line) |
|---|---|
| `api_server.py` | FastAPI app + all endpoints (the entry point). |
| `requirements.txt` | Python dependencies (also copied separately first for layer caching). |
| `Procfile` | Alt process definition (`web:` uvicorn) — for a Procfile-based host, not used by the Dockerfile CMD. |
| `recommender_system/` | CBF recommender package: `quote_recommender.py`, `main_pipeline.py`, `generate_embeddings.py`, and `quote_embeddings.npy` (precomputed SBERT vectors). |
| `dataset/` | `fer_gemini.py` (FER), `gemini_rewrite.py` (rewrite), `emotion_quotes.csv` (recommender source data), plus the dataset-build/scoring scripts and other CSVs. |
| `services/` | `emotion_store.py` (mood-history JSON store), `mood_analytics.py` (weekly dashboard builder). |
| `data/emotion_logs.json` | Server-side mood-history store written by `log_emotion`. |
| `build_final_dataset.py`, `evaluation.py`, `kappaanalysis.py`, `kappaanalysisresult.txt` | Offline dataset/eval scripts — copied but not used at runtime (dead weight in the image). |
| `expertreview ver_Motivational Quotes Dataset.xlsx` | Expert-review spreadsheet — copied but not used at runtime. |
| `CLAUDE.md`, `runlocalhost.txt` | Docs — copied but not used at runtime. |
| `api_service/`, `model/` | Present in the tree but **empty** directories. |

Excluded by `.dockerignore`: `venv/`, `__pycache__/`, `*.pyc`, `.env`, `.git`,
`notebooks/`, `mobile_app/`, `temp/`, and
`dataset/NRC-Emotion-Lexicon-Wordlevel-v0.92.txt`.

### .dockerignore (verbatim) — `.dockerignore`
```
venv/
__pycache__/
*.pyc
.env
.git
notebooks/
mobile_app/
temp/
dataset/NRC-Emotion-Lexicon-Wordlevel-v0.92.txt
```
(There is also a near-identical `.gcloudignore` with the same entries, minus the
trailing newline.)

### requirements.txt (verbatim) — `requirements.txt`
```
fastapi
uvicorn
python-multipart
python-dotenv
pillow
google-generativeai
sentence-transformers
pandas
scikit-learn
```
Note: **no versions are pinned** — every dependency floats to latest.

### Deployment config (cloudbuild.yaml / service.yaml / deploy script / Makefile)
**None exist.** Searched for `cloudbuild*`, `service.yaml`, `app.yaml`,
`Makefile`, `*deploy*`, `skaffold*` — the only build/deploy-adjacent files are
the `Dockerfile`, `Procfile`, `.dockerignore`, and `.gcloudignore`. There is no
CI config, no shell/PowerShell deploy script.

### Recorded deploy commands / service name / region / project ID
- **No `docker build`, `docker push`, or `gcloud run deploy` command is written
  down anywhere** in the repo. Not reconstructed here.
- The **local** run instructions are recorded in `runlocalhost.txt` (uvicorn on
  port 8000 with `--reload`, tethered to the laptop's IPv4) — dev-only, not the
  deployment.
- The deployed service is only evidenced indirectly by the client base URL in
  `mobile_app/flutter_app/lib/services/api_service.dart:7-8`:
  ```
  https://fequote-api-155804644015.asia-southeast1.run.app
  ```
  From that URL alone one can read a Cloud Run service in region
  **`asia-southeast1`** and the number **`155804644015`**. The Firebase
  `mobile_app/flutter_app/android/app/google-services.json` records
  `"project_id": "fyp-motivational-app"` and the same project number
  `155804644015`. The **service name is not explicitly stated** as config
  anywhere; it only appears embedded in that hostname (`fequote-api-…`). Treat
  these as observed values, not documented deploy parameters.

> ⚠️ **Discrepancy (Dockerfile):** `ENV PORT=8080` is set but the `CMD`
> hard-codes `--port 8080` instead of referencing `$PORT`. The env var is
> effectively dead in the Docker path. Cloud Run injects its own `$PORT`
> (default 8080), so this works only because the hard-coded value matches the
> default — a different `$PORT` would be ignored. The `Procfile` *does* honour
> `$PORT`, so the two entry definitions disagree.

---

## Q2 — Backend framework and entry point

### Framework and version
- **FastAPI**, served by **Uvicorn** — `api_server.py:2-3`, declared in
  `requirements.txt:1-2`.
- **Version: unpinned.** Neither `fastapi` nor `uvicorn` has a version
  constraint in `requirements.txt`, so no version is fixed by the repo.

### Startup command and port
- Container startup: `Dockerfile:20` → `uvicorn api_server:app --host 0.0.0.0 --port 8080`.
- Exposed port: **8080** (hard-coded in CMD; `ENV PORT=8080` also set but unused
  by CMD — see discrepancy above). There is no `EXPOSE` directive.
- The `if __name__ == "__main__"` block (`api_server.py:98-101`) also runs on
  port **8080**.

### Endpoints — `api_server.py`
| Method + path | Line | Purpose |
|---|---|---|
| `GET /` | 31-33 | Health check; returns `{"message": "API is running"}`. |
| `POST /analyze` | 36-62 | Accepts an image (+ optional `device_id`), runs FER via Gemini, returns detected emotion + confidence + recommended quotes, and logs the emotion server-side if a device_id is given. |
| `GET /quotes?emotion=` | 65-76 | Image-free fallback: returns quotes for a manually chosen emotion via the same CBF recommender. |
| `GET /mood/weekly?device_id=` | 79-86 | Builds the weekly mood dashboard from the server-side JSON records for that device. |
| `POST /rewrite` | 89-95 | Rewrites a quote given `{quote, context}` via Gemini. |

---

## Q3 — Embedding generation script

### generate_embeddings.py (full) — `recommender_system/generate_embeddings.py`
```python
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
```

### Model, dimension, output
- **SBERT model:** `all-MiniLM-L6-v2` (line 9).
- **Embedding dimension:** the repo does not state it in code; `all-MiniLM-L6-v2`
  produces **384-dimensional** vectors (a fact about that model, not written in
  the file). The shape isn't asserted anywhere in the repo.
- **Output write:** `np.save("quote_embeddings.npy", embeddings)` (line 20) — a
  NumPy `.npy` binary written **relative to the current working directory**, so
  it must be run from inside `recommender_system/`. The committed vectors live at
  `recommender_system/quote_embeddings.npy`.

### Run manually or by a build step?
**Manual only.** Nothing imports or invokes it — no reference in the Dockerfile,
Procfile, `api_server.py`, or any other file. The recommender consumes the
pre-committed `quote_embeddings.npy` at runtime; the embeddings are never
regenerated during build or deploy.

> ⚠️ **Discrepancy:** `generate_embeddings.py` reads
> `"../dataset/emotion_quotes.csv"` (a relative path assuming CWD =
> `recommender_system/`), whereas the runtime recommender resolves the same CSV
> with an absolute path built from `__file__`
> (`recommender_system/quote_recommender.py:9-13`). The generator is
> path-fragile; the consumer is not.

---

## Q4 — Recommender implementation

### Recommendation function (full body) — `recommender_system/quote_recommender.py:33-67`
```python
def recommend_quotes(emotion, top_n=5):
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

    # Randomly select final quotes
    selected_quotes = random.sample(top_pool, min(top_n, len(top_pool)))

    return selected_quotes
```
(It filters the dataset to the detected emotion, ranks that subset by cosine
similarity to the SBERT encoding of the emotion word, keeps the top-10 pool, then
randomly samples 5.)

### Dataset + embeddings load, with caching — `recommender_system/quote_recommender.py:8-30`
```python
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
```
Caching is lazy module-level memoisation: three globals (`data`, `embeddings`,
`model`) load once on first `recommend_quotes` call and are reused thereafter.

---

## Q5 — Gemini integration setup

### How the API key is supplied
- **Environment variable**, loaded from a `.env` file via `python-dotenv`. The
  read line is `dataset/fer_gemini.py:16`:
  ```python
  API_KEY = os.getenv("GEMINI_API_KEY")
  ```
  with `load_dotenv()` at line 7. A `.env` file exists locally but is
  git/dockerignored (never baked into the image), so at deploy time
  `GEMINI_API_KEY` must come from the Cloud Run environment. **No secret-manager
  or config-file mechanism is present in the repo.**

### Client initialisation (both features)
Both features share **one** client initialiser — `dataset/fer_gemini.py:9-24`:
```python
client = None


def get_client():
    global client

    if client is None:
        API_KEY = os.getenv("GEMINI_API_KEY")

        if not API_KEY:
            raise ValueError("GEMINI_API_KEY not found")

        genai.configure(api_key=API_KEY)
        client = genai.GenerativeModel("gemini-2.5-flash")

    return client
```
The rewrite feature does **not** create its own client — it imports and reuses
this one: `dataset/gemini_rewrite.py:2` → `from dataset.fer_gemini import get_client`.

### Prompts (verbatim)

**FER prompt** — `dataset/fer_gemini.py:49-59`:
```
You are a facial emotion recognition system.

Analyze the human facial expression.

Return ONLY one of:
happy, sad, angry, surprise

If you are NOT confident or no clear face/emotion is visible:
return exactly: no emotion
```

**Rewrite prompt** — `dataset/gemini_rewrite.py:4-28`:
```
You are a motivational quote rewriting assistant.

Given:
1. Original motivational quote
2. User situation/context

Rewrite the quote so it becomes more personal, encouraging and emotionally supportive.

Requirements:
- Preserve original meaning
- Maximum 50 words
- Simple English
- Positive tone
- Return only the rewritten quote
- No explanation
- No quotation marks
- No markdown formatting

Original quote:
{quote}

User context:
{context}
```

### Model string and SDK — consistency
- Both features use model **`gemini-2.5-flash`** and SDK
  **`import google.generativeai as genai`** (the `google-generativeai` package),
  because rewrite calls the same `get_client()`.
- **No inconsistency** between the two features. Caveat for the report:
  `google-generativeai` is the *legacy* Gemini SDK (superseded by `google-genai`),
  and it's unpinned in `requirements.txt` — a floating major-version dependency
  on a deprecated library.

> ⚠️ **Note on confidence values:** the `confidence` returned by FER is **not** a
> real model probability — `_map_emotion_result` (`dataset/fer_gemini.py:27-39`)
> assigns hard-coded constants (0.92/0.88/0.86/0.90) by keyword-matching Gemini's
> text output. Relevant if the report describes "confidence" as measured.

---

## Q6 — Notifications implementation

### Scheduling code (with `zonedSchedule`) — `mobile_app/flutter_app/lib/services/local_notification_service.dart:92-105`
```dart
static Future<void> scheduleDailyNotification({
  required int hour,
  required int minute,
}) async {
  await _notifications.zonedSchedule(
    id: dailyReminderId,
    title: 'Daily Check-In',
    body: 'How are you feeling today? Take a moment to reflect. 🌸',
    scheduledDate: _nextInstance(hour, minute),
    notificationDetails: _details,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
```
`dailyReminderId = 1001` (line 38); `matchDateTimeComponents: DateTimeComponents.time`
makes it repeat daily at the same time; `_nextInstance` (lines 111-119) rolls to
tomorrow if the time already passed today.

### Package and version — `mobile_app/flutter_app/pubspec.yaml:39`
```
flutter_local_notifications: ^21.0.0
```
(Supporting: `timezone: ^0.11.0` at line 42, used to pin `tz.local` to
`Asia/Kuala_Lumpur`.) It is a **local** notification (device AlarmManager),
**not** FCM — no server/push involved.

### Path from Settings screen → schedule
1. `mobile_app/flutter_app/lib/screens/settings_screen.dart:176` →
   `await context.read<SettingsProvider>().pickTime(context)`.
2. `pickTime` (`settings_provider.dart:125-135`) shows `showTimePicker`, stores
   the result in `_selectedTime`, calls `saveSettings()`.
3. `saveSettings` (`settings_provider.dart:70-102`) →
   `LocalNotificationService.scheduleDailyNotification(hour: _selectedTime.hour, minute: _selectedTime.minute)`.
   - The toggle takes the same route via `toggleNotification` → `saveSettings`
     (lines 119-123).
   - On app launch, `ensureScheduledOnStartup` (lines 107-117) re-arms it from
     saved prefs.

### Is the reminder time persisted?
Yes, in **two** places:
- **Locally** via `shared_preferences` as integer `reminder_hour` /
  `reminder_minute` (+ bool `reminder_enabled`) — `settings_provider.dart:76-78`.
- **Firestore** collection `notification_preferences`, doc keyed by `device_id`,
  as a `"HH:mm"` string field `reminder_time` (+ bool `daily_reminder`) —
  `settings_provider.dart:80-87`. On startup it loads local first, then
  reconciles from Firestore (`_syncFromFirestore`, lines 43-68).

### Notification content
**Hardcoded.** Title `'Daily Check-In'` and body
`'How are you feeling today? Take a moment to reflect. 🌸'` are string literals in
`scheduleDailyNotification` (lines 98-99). It does **not** pull a quote or any
dynamic content.

---

## Q7 — Firestore write

### The mood-history Firestore write — `mobile_app/flutter_app/lib/services/emotion_history_service.dart:6-17`
```dart
Future<void> saveRecord({
  required String deviceId,
  required String emotion,
  required double confidence,
}) async {
  await FirebaseFirestore.instance.collection(_collection).add({
    'device_id': deviceId,
    'emotion': emotion.toLowerCase(),
    'confidence': confidence,
    'timestamp': FieldValue.serverTimestamp(),
  });
}
```
- **Collection:** `emotion_records` (`_collection`, line 4); `.add()`
  auto-generates the doc ID.
- **Fields written:** `device_id` (string), `emotion` (lowercased string),
  `confidence` (double), `timestamp` (server timestamp).
- Called from `mobile_app/flutter_app/lib/providers/reflect_provider.dart:30-34`,
  only when `deviceId != null` and emotion `!= 'no emotion detected'`.

> ⚠️ **Major discrepancy — dual, divergent mood-history stores.** The backend
> *also* persists mood history independently, but to a **local JSON file**, not
> Firestore: `POST /analyze` → `log_emotion` writes to `data/emotion_logs.json`
> (`services/emotion_store.py:24-36`). So one capture writes history **twice** —
> once to Firestore from the client, once to server JSON. The dashboard reads the
> **server JSON** via `/mood/weekly` and only **falls back** to Firestore if the
> API fails (`mood_dashboard_service.dart:8-25`). There is **no Firestore SDK on
> the backend** — the server side of "Firestore" is actually a flat JSON file.

### How `device_id` is obtained — `settings_provider.dart:18-25`
```dart
Future<void> init() async {
  final prefs = await SharedPreferences.getInstance();
  _deviceId = prefs.getString('device_id');

  if (_deviceId == null) {
    _deviceId = const Uuid().v4();
    await prefs.setString('device_id', _deviceId!);
  }
  ...
```
A random UUID v4 generated once (via the `uuid` package) and cached in
`shared_preferences` under key `device_id`. It's **anonymous and device-local** —
not tied to any user account. `ReflectScreen` ensures it exists before capture
(`reflect_screen.dart:59-61`).

### Firebase config in the repo, and is Authentication used?
- **Config present:** `mobile_app/flutter_app/android/app/google-services.json`
  exists (`project_id: fyp-motivational-app`, project number `155804644015`,
  `package_name: com.example.flutter_app`).
- **`firebase_options.dart` does NOT exist** — the app initialises with a bare
  `Firebase.initializeApp()` (`main.dart:19`), relying on the native
  `google-services.json` rather than the FlutterFire generated options. No iOS
  `GoogleService-Info.plist` and no `firebase.json` in the repo either.
- **Services actually initialised/used:** only **`firebase_core`** (init) and
  **`cloud_firestore`** (`emotion_records` and `notification_preferences`
  collections). Those are the only two Firebase packages in
  `pubspec.yaml:37-38`.
- **Authentication is genuinely unused** — confirmed: no `firebase_auth`
  dependency, no `FirebaseAuth` reference anywhere in `lib/`. Identity is handled
  entirely by the anonymous device UUID. (The `oauth_client`/`api_key` blocks in
  `google-services.json` are standard boilerplate Firebase emits for every
  Android app; they don't imply Auth is wired up.)

> ⚠️ Minor: `package_name` is still the default placeholder
> `com.example.flutter_app` — never rebranded.

---

## Q8 — Flutter app setup

### Dependency list — `mobile_app/flutter_app/pubspec.yaml:30-49` (runtime) and 51-62 (dev)
```yaml
dependencies:
  flutter:
    sdk: flutter

  http: ^1.2.1
  google_fonts: ^8.1.0
  camera: ^0.12.0+1
  firebase_core: ^4.7.0
  cloud_firestore: ^6.3.0
  flutter_local_notifications: ^21.0.0
  shared_preferences: ^2.3.2
  uuid: ^4.5.1
  timezone: ^0.11.0
  provider: ^6.1.2
  intl: ^0.20.2
  speech_to_text: ^7.0.0
  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^0.14.4
  flutter_lints: ^6.0.0
```

### SDK versions pinned
- **Dart SDK:** `sdk: ^3.10.7` — `pubspec.yaml:22`.
- **Flutter SDK:** **not pinned.** There is no `flutter:` version constraint under
  `environment:` (only the Dart `sdk` line). So the repo fixes the Dart SDK floor
  but not a Flutter version.

### Camera/capture snippet — `mobile_app/flutter_app/lib/screens/reflect_screen.dart:33-76`
```dart
Future<void> _initCamera() async {
  cameras = await availableCameras();
  _controller = CameraController(
    cameras![cameraIndex],
    ResolutionPreset.medium,
  );
  await _controller!.initialize();
  if (mounted) setState(() {});
}
...
Future<void> _captureAndSend() async {
  final reflectProvider = context.read<ReflectProvider>();
  final quoteProvider = context.read<QuoteProvider>();
  final settings = context.read<SettingsProvider>();

  if (settings.deviceId == null) {
    await settings.init();
  }

  final image = await _controller!.takePicture();
  final result = await reflectProvider.captureAndDetect(
    File(image.path),
    deviceId: settings.deviceId,
  );

  if (result != null && mounted) {
    reflectProvider.updateQuoteFromResult(quoteProvider, result);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResultScreen()),
    );
  }
}
```
The actual multipart HTTP POST to `/analyze` lives one layer down in
`mobile_app/flutter_app/lib/services/api_service.dart:10-50` (called via
`ReflectProvider.captureAndDetect`).

### Theming / design system
Yes — a single design-token file:
`mobile_app/flutter_app/lib/constants/app_theme.dart` (225 lines), class
`AppTheme`. It's the documented single source of truth for colour (brand
purples/peach gradient, `emotionColors` map), typography (Google Fonts), spacing
scale (`spaceXs…spaceXl`), radii, elevation (`cardShadow`), and accessibility
tokens (`minTapTarget`). Applied app-wide via `theme: AppTheme.lightTheme` in
`main.dart:43`. No dark theme, no per-screen theme files.

---

## Q9 — Repo structure

### Directory tree (2–3 levels, excluding `venv/`, `.git/`, `build/`, `.dart_tool/`, `__pycache__/`, platform folders)
```
fequote_1/
├── api_server.py                 # FastAPI entry point (backend)
├── Dockerfile / Procfile / requirements.txt / .dockerignore / .gcloudignore
├── build_final_dataset.py        # dataset pipeline
├── evaluation.py                 # eval script (precision/recall/DCG)
├── kappaanalysis.py / kappaanalysisresult.txt   # eval (Cohen's Kappa)
├── expertreview ver_Motivational Quotes Dataset.xlsx
├── CLAUDE.md / runlocalhost.txt
├── api_service/                  # (empty)
├── model/                        # (empty)
├── data/
│   └── emotion_logs.json         # server-side mood-history JSON store
├── dataset/                      # dataset pipeline + FER/rewrite + data
│   ├── fer_gemini.py  gemini_rewrite.py
│   ├── prepare_dataset.py  nrc_scoring_v2.py
│   ├── quotes.csv  clean_quotes.csv  emotion_quotes.csv  nrc_scored_quotes_v2.csv
│   ├── NRC-Emotion-Lexicon-Wordlevel-v0.92.txt
│   └── test_images/
├── recommender_system/           # CBF recommender (backend)
│   ├── quote_recommender.py  main_pipeline.py  generate_embeddings.py
│   └── quote_embeddings.npy
├── services/                     # backend services
│   ├── emotion_store.py  mood_analytics.py
├── notebooks/                    # (empty)
├── temp/                         # scratch capture images (gitignored from image)
└── mobile_app/
    └── flutter_app/              # the Flutter app
        ├── pubspec.yaml
        ├── lib/
        │   ├── main.dart  app_routes.dart
        │   ├── constants/   (app_theme.dart — design system)
        │   ├── models/  providers/  viewmodels/
        │   ├── screens/     (welcome, reflect, result, quote, settings, main_navigation)
        │   ├── views/       (mood_dashboard_screen, ai_rewrite_screen)
        │   ├── services/    (api_service, emotion_history, notifications, …)
        │   └── widgets/     (app_bottom_nav_bar, mood_bubble, glass_container, …)
        ├── assets/images/
        └── android/ ios/ web/ windows/ linux/ macos/ test/
```

### Role of each area
- **Flutter app:** `mobile_app/flutter_app/` (all UI in `lib/`).
- **Backend (FastAPI service):** `api_server.py` + `recommender_system/` (CBF) +
  `services/` (mood store & analytics) + the FER/rewrite modules
  `dataset/fer_gemini.py` and `dataset/gemini_rewrite.py` + `data/` (JSON store).
  Containerised by `Dockerfile`.
- **Dataset pipeline scripts:** `dataset/prepare_dataset.py` (clean/dedup/
  lang-detect quotes), `dataset/nrc_scoring_v2.py` (NRC lexicon emotion scoring),
  `build_final_dataset.py` (rebuild `emotion_quotes.csv`),
  `recommender_system/generate_embeddings.py` (SBERT vectors).
- **Evaluation scripts:** `evaluation.py` (ranking metrics: precision/recall/DCG)
  and `kappaanalysis.py` (Cohen's Kappa, NRC vs expert agreement) with its output
  `kappaanalysisresult.txt`.
- **Empty/scratch:** `api_service/`, `model/`, `notebooks/` are empty; `temp/`
  holds scratch capture images.

---

## Cross-cutting discrepancies (summary)
1. **Dockerfile port:** `ENV PORT=8080` is dead — CMD hard-codes the port instead
   of using `$PORT`; disagrees with the `$PORT`-aware Procfile. (Q1/Q2)
2. **No pinned versions** in `requirements.txt`; Flutter SDK unpinned in
   `pubspec.yaml`. (Q1/Q8)
3. **Dual mood-history stores that can diverge:** client writes Firestore
   `emotion_records`; server writes `data/emotion_logs.json`; dashboard prefers
   the server JSON, Firestore is only a fallback. "Firestore backend" is really a
   flat file server-side. (Q4/Q7)
4. **FER "confidence" is fabricated** — hard-coded constants keyed off Gemini's
   text, not a model probability. (Q5)
5. **Legacy Gemini SDK** (`google-generativeai`), unpinned. (Q5)
6. **`generate_embeddings.py` path-fragile** (CWD-relative) vs the runtime
   recommender's `__file__`-absolute path. (Q3/Q4)
7. **No deploy config or recorded deploy commands** anywhere; Cloud Run
   region/project only inferable from the hard-coded client URL and
   `google-services.json`. (Q1)
8. **Placeholder Android package name** `com.example.flutter_app`. (Q7)
9. **`SUMMARY_TEXT` includes a `"Balanced"` key** in `services/mood_analytics.py:6-11`
   that the CLAUDE.md documented summary categories (`Positive` / `Needs Support`
   / `Emotionally Strained`) omit — a doc-vs-code drift. (Reference)
