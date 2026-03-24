# TimeWise

**Instructor:** Asst. Prof. Yigit Bekir Kaya &nbsp;|&nbsp; **Course:** SWE314 – Web Programming, Istinye University

> *"Learn something useful. Reset your mind. Use short time better."*

TimeWise is a personalized short-break companion that recommends content — articles, videos, podcasts, games, books, music playlists and documentaries — based on how much time you have, what you want to do, and how you like to learn.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Tech Stack](#tech-stack)
- [Database Schema](#database-schema)
- [Entities & Relationships](#entities--relationships)
- [Recommendation Engine](#recommendation-engine)
- [API Endpoints](#api-endpoints)
- [Pydantic Validation](#pydantic-validation)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [HTTP Status Codes](#http-status-codes)
- [Development Stages](#development-stages)

---

## Project Overview

| Field | Value |
|---|---|
| **Problem** | People have short, fragmented free time but no tool to fill it meaningfully |
| **Solution** | A session-based recommendation engine that matches content to available time + user intent |
| **Database** | PostgreSQL (17 tables, M-to-N relationships, ENUM types) |
| **Backend** | FastAPI + SQLAlchemy (typed ORM) + Pydantic v2 |
| **Frontend** | React 18 + Vite + React Router v6 |
| **Auth** | JWT (python-jose + passlib/bcrypt) |

### Core User Flow

| Step | User Action | System Response |
|---|---|---|
| 1 | Register / Login | JWT token issued, user_stats row created |
| 2 | Onboarding — pick topics | Topic weights stored in `user_topics` |
| 3 | Enter available time + goal | `time_sessions` row created |
| 4 | Request recommendations | Scoring engine runs, top 6 results returned |
| 5 | Open / save / play content | `bookmarks`, `progress`, `was_opened` updated |
| 6 | Finish session | XP awarded, `user_stats` updated |
| 7 | View dashboard | Weekly chart, achievements, stats displayed |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Database | PostgreSQL 16 |
| ORM | SQLAlchemy 2 (typed `Mapped` columns) |
| Backend | FastAPI + Uvicorn |
| Validation | Pydantic v2 (`Field`, `EmailStr`, ENUM validation) |
| Auth | JWT via `python-jose`, password hashing via `passlib[bcrypt]==4.0.1` |
| Frontend | React 18 + Vite |
| Routing | React Router v6 |
| Charts | Recharts |
| HTTP Client | Native `fetch` with JWT interceptor |

---

## Database Schema

### Entity Summary (17 tables)

| Table | Purpose |
|---|---|
| `users` | User accounts (email, username, display_name, onboarding_completed) |
| `user_preferences` | Default goal, difficulty, offline preference |
| `topics` | 12 interest categories (Tech, Music, Philosophy…) |
| `topic_subtags` | Sub-chips under each topic (AI Tools, Guitar, Stoicism…) |
| `user_topics` | **M-to-N** — user ↔ topic with `weight` (1–10) |
| `onboarding_questions` | Configurable onboarding question bank |
| `user_onboarding_answers` | Saved answers per user |
| `authors` | Content creators and educators |
| `contents` | 250+ content items (article/video/podcast/game/book/playlist/documentary) |
| `content_topics` | **M-to-N** — content ↔ topic |
| `time_sessions` | Each recommendation request (available_minutes, goal, difficulty) |
| `recommendations` | Scored + ranked content per session |
| `bookmarks` | **M-to-N** — user ↔ content (saved items) |
| `progress` | Per-user completion percentage per content |
| `user_stats` | Denormalized analytics cache (XP, level, streak, totals) |
| `achievements` | 16 badge definitions (bronze → platinum tiers) |
| `user_achievements` | **M-to-N** — user ↔ achievement + earned_at |

### Key Relationships

```
User ──< UserTopic >── Topic ──< ContentTopic >── Content
User ──< TimeSession ──< Recommendation >── Content
User ──< Bookmark >── Content
User ──< Progress >── Content
User ──< UserAchievement >── Achievement
User ── UserStat
Content ── Author
Topic ──< TopicSubtag
```

### PostgreSQL ENUM Types

```sql
CREATE TYPE content_type    AS ENUM ('article','video','podcast','flashcard',
                                      'exercise','journaling','tutorial','quiz',
                                      'book_summary','book','game','music_playlist','documentary');
CREATE TYPE learning_goal   AS ENUM ('learn','focus','relax','productive','create');
CREATE TYPE difficulty_level AS ENUM ('beginner','intermediate','advanced');
CREATE TYPE session_status  AS ENUM ('active','completed','abandoned');
CREATE TYPE badge_tier      AS ENUM ('bronze','silver','gold','platinum');
```

---

## Recommendation Engine

Located in `backend/services/recommender.py`. Scores every published content item and returns the top 6.

### Scoring Breakdown (max 100 pts)

| Criterion | Weight | Logic |
|---|---|---|
| Duration match | 40 pts | Closeness of `duration_minutes` to `available_minutes` |
| Topic match | 25 pts | Best `weight` from `user_topics` for overlapping topics |
| Goal match | 15 pts | Content type mapped to session goal |
| Difficulty match | 10 pts | Exact match on difficulty level |
| Offline compatibility | 5 pts | If session is offline, content must be offline-available |
| Rating bonus | 5 pts | Normalized `avg_rating / 5.0` |

### Goal → Content Type Mapping

| Goal | Suitable Content Types |
|---|---|
| learn | article, video, book_summary, tutorial, quiz |
| focus | flashcard, exercise, tutorial |
| relax | video, podcast, music_playlist, documentary, exercise, journaling |
| productive | article, podcast, tutorial, quiz |
| create | game, journaling, video, tutorial |

### Fallback
If zero items score above 0, the engine widens the duration filter and returns the best duration + rating matches regardless of topic.

### Reason Labels
Each recommendation carries a `reason_template` chip and a human-readable `reason_text`:

| Template | Meaning |
|---|---|
| `matches_topic` | Content topic matches user's top interest |
| `matches_goal` | Content type aligns with session goal |
| `fits_duration` | Duration fits the available window closely |
| `top_rated` | Highly rated by platform users |
| `offline_available` | Works without internet |

---

## API Endpoints

### Auth `/auth`

| Method | Path | Description | Status |
|---|---|---|---|
| POST | `/auth/register` | Create account + issue JWT | 200 |
| POST | `/auth/login` | Login + issue JWT | 200 |
| GET | `/auth/me` | Current user info | 200 |

### Topics & Onboarding

| Method | Path | Description | Status |
|---|---|---|---|
| GET | `/topics` | All topics with subtags | 200 |
| POST | `/onboarding/complete` | Save selected topics, mark onboarding done | 200 |
| GET | `/users/me/topics` | User's topic weights | 200 |
| POST | `/users/me/topics` | Update topic weights | 200 |

### Sessions & Recommendations `/sessions`

| Method | Path | Description | Status |
|---|---|---|---|
| POST | `/sessions` | Create session + generate recommendations | 200 |
| GET | `/sessions` | List user's sessions | 200 |
| GET | `/sessions/{id}/recommendations` | Get ranked recommendations | 200 |
| PATCH | `/sessions/{id}/complete` | Mark completed, award XP | 200 |

### Content `/contents`

| Method | Path | Description | Status |
|---|---|---|---|
| GET | `/contents` | Catalog with filters (`content_type`, `max_duration`, `sort`, `limit`) | 200 |

### Bookmarks `/bookmarks`

| Method | Path | Description | Status |
|---|---|---|---|
| GET | `/bookmarks` | List saved content | 200 |
| POST | `/bookmarks/{content_id}` | Save content | 200 |
| DELETE | `/bookmarks/{content_id}` | Remove bookmark | 200 |

### Progress `/progress`

| Method | Path | Description | Status |
|---|---|---|---|
| GET | `/progress` | List all progress entries | 200 |
| PUT | `/progress/{content_id}` | Upsert completion percentage | 200 |

### Dashboard `/dashboard`

| Method | Path | Description | Status |
|---|---|---|---|
| GET | `/dashboard` | Summary stats (XP, level, streak, totals) | 200 |
| GET | `/dashboard/stats` | Full user_stats with favorite topic | 200 |
| GET | `/dashboard/achievements` | Earned achievements | 200 |
| GET | `/dashboard/continue` | Latest incomplete progress item | 200 |
| GET | `/dashboard/weekly-activity` | Last 7 days — minutes per day | 200 |

### Achievements `/achievements`

| Method | Path | Description | Status |
|---|---|---|---|
| GET | `/achievements/vitrine` | All 16 badges with earned/locked state | 200 |

---

## Pydantic Validation

All request bodies are validated by Pydantic v2 models in `backend/schemas/schemas.py`.

### Examples

```python
class RegisterIn(BaseModel):
    email:    EmailStr                          # must be valid email format
    username: str = Field(min_length=3, max_length=80)
    password: str = Field(min_length=6, max_length=128)

class SessionCreateIn(BaseModel):
    available_minutes: int = Field(ge=1, le=240)   # 1–240 minutes
    goal:       Optional[GoalEnum]     = None       # ENUM validation
    difficulty: Optional[DifficultyEnum] = None
    selected_topic_id: Optional[int]   = None
    is_offline: bool = False

class ProgressUpdateIn(BaseModel):
    completion_percentage: int = Field(ge=0, le=100)  # 0–100 only
```

FastAPI automatically returns **422 Unprocessable Entity** with field-level error detail when validation fails.

---

## Project Structure

```
Time_Wise/
├── backend/
│   ├── core/
│   │   ├── config.py          # Settings via pydantic-settings + lru_cache
│   │   ├── database.py        # SQLAlchemy engine + session
│   │   └── security.py        # JWT encode/decode, bcrypt hashing
│   ├── models/
│   │   ├── models.py          # All 17 SQLAlchemy ORM models
│   │   └── user.py            # User model (separated for circular import safety)
│   ├── routers/
│   │   ├── auth.py            # Register, login, /me
│   │   ├── onboarding.py      # Topic selection + user_topics CRUD
│   │   ├── sessions.py        # Session lifecycle + recommendations
│   │   ├── bookmarks.py       # Save / remove bookmarks
│   │   ├── progress.py        # Upsert completion percentage
│   │   ├── content.py         # Catalog with filters
│   │   ├── dashboard.py       # Stats, weekly activity, continue widget
│   │   └── achievements.py    # Badge vitrine
│   ├── schemas/
│   │   └── schemas.py         # All Pydantic v2 request/response models
│   ├── services/
│   │   └── recommender.py     # Scoring engine + fallback logic
│   ├── main.py                # FastAPI app, CORS, router registration
│   ├── requirements.txt
│   └── .env.example
├── frontend/
│   ├── src/
│   │   ├── api/
│   │   │   └── index.js       # Fetch wrapper + all API calls
│   │   ├── components/
│   │   │   ├── ContentCard.jsx    # Recommendation card (game/book/youtube aware)
│   │   │   ├── CatalogCard.jsx    # Explore page card
│   │   │   ├── Navbar.jsx
│   │   │   ├── ProgressCharts.jsx # Recharts weekly bar chart
│   │   │   ├── ThemeToggle.jsx    # Dark / light mode toggle
│   │   │   └── YouTubePlayer.jsx  # Inline YouTube embed
│   │   ├── context/
│   │   │   ├── AuthContext.jsx    # JWT auth state
│   │   │   └── ThemeContext.jsx   # Dark/light theme state
│   │   ├── pages/
│   │   │   ├── Auth.jsx           # Login + Register
│   │   │   ├── Onboarding.jsx     # Topic selection grid
│   │   │   ├── Dashboard.jsx      # Home: session creator + recommendations + stats
│   │   │   ├── Explore.jsx        # Catalog with horizontal scroll sections
│   │   │   ├── Bookmarks.jsx      # Saved content
│   │   │   └── Progress.jsx       # Progress tracking + achievement vitrine
│   │   ├── utils/
│   │   │   ├── youtube.js         # YouTube URL → video ID parser
│   │   │   └── goalContentMap.js  # Goal → content type mapping (frontend copy)
│   │   ├── lib/
│   │   │   └── youtubeIframeApi.js
│   │   └── styles.css             # Global CSS (no Tailwind)
│   ├── index.html
│   ├── vite.config.js
│   └── package.json
├── screenshots/               # App screenshots
├── responsibilities/          # Team member task breakdown
├── .gitignore
└── README.md
```

---

## Getting Started

### Prerequisites
- Python 3.11+
- Node.js 18+
- PostgreSQL 14+

### 1 — Database

```bash
# Create database
createdb timewise_db

# Load schema + seed data
psql -d timewise_db -f timewise_database_v7.sql
```

### 2 — Backend

```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS / Linux

pip install -r requirements.txt

cp .env.example .env
# Edit .env — set DATABASE_URL and SECRET_KEY
```

**.env example:**
```env
DATABASE_URL=postgresql+psycopg://postgres:YOUR_PASSWORD@localhost:5432/timewise_db
SECRET_KEY=your-secret-key-here
CORS_ORIGIN=http://localhost:5173
```

```bash
uvicorn main:app --reload --port 8001
```

- Health check: `http://localhost:8001/health`
- Swagger UI: `http://localhost:8001/docs`
- ReDoc: `http://localhost:8001/redoc`

### 3 — Frontend

```bash
cd frontend
npm install
npm run dev
```

App runs at `http://localhost:5173`

---

## HTTP Status Codes

| Code | Meaning | When |
|---|---|---|
| 200 | OK | Successful GET, POST, PUT, PATCH |
| 201 | Created | *(reserved for future use)* |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Email/username duplicate, invalid topic |
| 401 | Unauthorized | Missing or invalid JWT token |
| 404 | Not Found | Session, content, or user not found |
| 422 | Unprocessable Entity | Pydantic validation failure (auto by FastAPI) |

---

## Development Stages

### Stage 1 — Database Design
- Designed 17-table PostgreSQL schema
- Defined M-to-N relationships: `user_topics`, `content_topics`, `bookmarks`, `user_achievements`
- Created PostgreSQL ENUM types for type safety
- Seeded 250+ real content items (YouTube, Gutenberg, Standard Ebooks)
- Added embedded HTML5 games (2048, Tetris, Snake, Sudoku, Minesweeper…)

### Stage 2 — Backend Core
- FastAPI project structure with layered architecture (routers / services / models / schemas)
- SQLAlchemy typed ORM models (`Mapped` columns)
- Pydantic v2 request/response schemas with `Field` constraints
- JWT authentication (register → token → protected routes)
- CORS middleware with localhost regex for flexible dev ports

### Stage 3 — Recommendation Engine
- Weighted scoring algorithm (duration 40% + topic 25% + goal 15% + difficulty 10% + offline 5% + rating 5%)
- Goal → content type mapping
- Fallback engine when strict filters return zero results
- `reason_template` + `reason_text` per recommendation

### Stage 4 — Full API
- Session lifecycle: create → recommend → complete → XP award
- Bookmark system with duplicate-safe `IntegrityError` handling
- Progress upsert with `total_contents_completed` sync
- Dashboard: summary stats, weekly activity (last 7 days), continue widget
- Achievement vitrine: all 16 badges with earned/locked state
- Content catalog with `content_type`, `max_duration`, `sort`, `limit` filters

### Stage 5 — Frontend
- React 18 + Vite + React Router v6
- JWT auth context with localStorage persistence
- Protected routes + onboarding redirect guard
- Dashboard: session creator (time slider + goal + difficulty + topic override + offline toggle)
- Inline YouTube player via iframe API
- HTML5 game popup renderer (embedded_html → new window)
- Explore page with horizontal scroll catalog sections
- Progress page with Recharts weekly bar chart + achievement vitrine
- Dark / light theme toggle

---

## Key Concepts Covered

- **PostgreSQL ENUM types** — database-level type enforcement for goal, difficulty, content_type, session_status, badge_tier
- **M-to-N relationships** — `user_topics`, `content_topics`, `bookmarks`, `user_achievements` with `UniqueConstraint`
- **Pydantic v2 validation** — `Field(ge=1, le=240)`, `EmailStr`, ENUM validation, auto 422 responses
- **JWT authentication** — stateless token auth, `OAuth2PasswordBearer`, `decode_token` on every protected route
- **Recommendation scoring** — multi-criteria weighted algorithm with deterministic fallback
- **Typed SQLAlchemy ORM** — `Mapped[int]`, `mapped_column`, relationship lazy loading with `joinedload`
- **Denormalized analytics cache** — `user_stats` updated on session complete / progress update
- **Proper HTTP status codes** — 400 for business rule violations, 401 for auth, 404 for not found, 422 for validation

## Screenshots

![Login](screenshots/login.jpeg)
![Onboarding](screenshots/onboarding.jpeg)
![Dashboard](screenshots/dashboard1.jpeg)
![Recommendations](screenshots/dashboard2.jpeg)

