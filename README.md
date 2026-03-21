# TimeWise

PostgreSQL + FastAPI backend + React (Vite) frontend. **UI copy is English.**

## Quick start

### Database
Create DB and load schema + seed (your `timewise_database_v7.sql`).

### Backend
```bash
cd timewise-backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # set DATABASE_URL + CORS_ORIGIN to match your machine
uvicorn main:app --reload --host 0.0.0.0 --port 8001
```

Health: `http://localhost:8001/health`  
Docs: `http://localhost:8001/docs`

### Frontend
```bash
cd timewise-frontend
npm install
npm run dev -- --port 5175
```

Set `timewise-frontend/src/api/index.js` `API_BASE` to your backend URL (e.g. `http://localhost:8001`).

Match `CORS_ORIGIN` in backend `.env` to the Vite URL (e.g. `http://localhost:5175`).

## Auth
JWT in `localStorage` key `tw_token`.

## App routes (frontend)
| Path | Page |
|------|------|
| `/` | Dashboard — time + mode + recommendations, `user_stats` summary, continue widget |
| `/explore` | Explore — catalog with horizontal sections |
| `/bookmarks` | Bookmarks |
| `/progress` | Progress — weekly chart (Recharts), badge showcase |
| `/dashboard` | Redirects to `/` |

## API additions
- `GET /contents` — published catalog (`content_type`, `max_duration`, `sort`, `limit`)
- `GET /dashboard/continue` — latest incomplete progress (or `null`)
- `GET /dashboard/weekly-activity` — last 7 days, minutes per day (completed sessions)
- `GET /achievements/vitrine` — all badges + earned/locked

Styling uses `styles.css` (no Tailwind); cards use `hover-lift` shadows.
