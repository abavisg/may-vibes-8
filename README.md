# may-vibes-8

## Overview
MindFlip is a mobile mindfulness application designed to help users identify negative thoughts via text or voice, reframe them using a local LLM (Ollama), and store the results in a personal journal. It also includes an SOS mode offering quick calming techniques.

## Tech Stack
- **Mobile App:** Flutter
- **Backend:** Python 3 + FastAPI
- **LLM:** Ollama (local)
- **Database:** Supabase (PostgreSQL + Auth)

## Getting Started

### Prerequisites
- Python 3.10+
- Flutter SDK
- Ollama installed and running locally
- Supabase project URL & service key

### Backend Setup
```bash
cd backend
cp .env.example .env
# Edit .env with your OLLAMA_URL, OLLAMA_MODEL, SUPABASE_URL, SUPABASE_KEY
pip install -r requirements.txt
```

### Running the Backend
From the root of the repo:
```bash
./scripts/restart-server.sh
```
This will generate a self-signed certificate (if needed), kill any existing Uvicorn processes, and start FastAPI over HTTPS on port 8000.

The server will now be available at:
- https://localhost:8000/
- Swagger UI: https://localhost:8000/docs
- ReDoc: https://localhost:8000/redoc

Since the certificate is self-signed, for CLI testing you can run:
```bash
curl -k https://localhost:8000/
```

**Emulator notes:**
- Android emulator (default host): https://10.0.2.2:8000/
- iOS simulator: https://localhost:8000/

### Mobile App Setup
```bash
cd mobile
flutter pub get
flutter run
```

The mobile app is located in the `mindflip/mobile` directory. It's structured into:

*   `lib/models/`: Data models (`ReframeResponse`, `JournalEntry`).
*   `lib/services/`: API communication (`ApiService`).
*   `lib/widgets/`: Reusable UI components (`ThoughtForm`, `TimelineGraph`).
*   `lib/screens/`: Page-level UI (`ReframeScreen`, `JournalScreen`, `SosScreen`).
*   `lib/main.dart`: App entry point.

The `ReframeScreen` now includes an icon in the AppBar to navigate to the `SosScreen` for immediate coping techniques, and another icon to navigate to the `JournalScreen` to view past entries.

You'll need a running instance of the backend for the mobile app to function. Follow the Backend Setup and Running instructions first.

## API Endpoints

Base URL: https://localhost:8000 (or https://10.0.2.2:8000 on Android emulator)

### Health Check
`GET /`
- Returns: `{ "message": "MindFlip backend is running." }`

### Reframe Thought
`POST /reframe`
- Request body:
  ```json
  { "thought": "I always fail" }
  ```
- Response body:
  ```json
  {
    "suggestions": ["...", "...", "..."],
    "tag": "Self-Doubt"
  }
  ```

### List Categories
`GET /categories`
- Returns: a JSON array of category names. Example:
  ```json
  [
    "Self-Doubt",
    "Catastrophizing",
    "Comparison",
    "Regret",
    "Control",
    "Negativity",
    "Anxiety",
    "Perfectionism"
  ]
  ```

### Save Journal Entry
`POST /entries`
- Request body:
  ```json
  {
    "original_thought": "I always mess up",
    "suggestion": "Mistakes are opportunities to grow.",
    "tag": "Growth-Mindset"
  }
  ```
- Response body:
  ```json
  {
    "id": 1,
    "original_thought": "I always mess up",
    "reframed_text": "Mistakes are opportunities to grow.",
    "category": "Growth-Mindset",
    "created_at": "2025-05-12T12:34:56.789Z"
  }
  ```

### List Journal Entries
`GET /entries`
- Returns: a JSON array of journal entries.
- Example:
  ```json
  [
    {
      "id": 1,
      "original_thought": "I always mess up",
      "reframed_text": "Mistakes are opportunities to grow.",
      "category": "Growth-Mindset",
      "created_at": "2025-05-12T12:34:56.789Z"
    },
    // ... more entries
  ]
  ```

### Get SOS Technique
`GET /sos`
- Query parameter (optional): `feeling=<current feeling>` (e.g., `/sos?feeling=anxious`)
- Returns: a plain text string with an immediate coping technique.
- Example:
  ```text
  Take a deep breath and count to four as you inhale, hold for four, and exhale for four.
  ```

## License
This project is licensed under the MIT License.