import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api";
import ContentCard from "../components/ContentCard";

const MAX_MINUTES = 240;
const quickMins = [15, 30, 45, 60, 75, 90, 105, 120];

function clampMinutes(n) {
  return Math.max(1, Math.min(MAX_MINUTES, n));
}

const MODES = [
  { id: "learn", goal: "learn", label: "Learn", className: "mode-card--learn" },
  { id: "focus", goal: "focus", label: "Focus", className: "mode-card--focus" },
  { id: "relax", goal: "relax", label: "Relax", className: "mode-card--relax" },
  { id: "productive", goal: "productive", label: "Productivity", className: "mode-card--productive" },
];

export default function Dashboard() {
  const [stats, setStats] = useState(null);
  const [cont, setCont] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [session, setSession] = useState(null);
  const [recs, setRecs] = useState([]);
  const [topics, setTopics] = useState([]);
  const [form, setForm] = useState({
    available_minutes: 25,
    goal: "learn",
    difficulty: "beginner",
    selected_topic_id: null,
    is_offline: false,
  });

  useEffect(() => {
    api.dashboardStats().then(setStats).catch(console.error);
    api.dashboardContinue().then(setCont).catch(() => setCont(null));
    api.getUserTopics().then(setTopics).catch(console.error);
  }, []);

  const createSession = async () => {
    setError("");
    setLoading(true);
    setRecs([]);
    try {
      const s = await api.createSession({
        ...form,
        available_minutes: Math.min(form.available_minutes, MAX_MINUTES),
      });
      setSession(s);
      const items = await api.recommendations(s.id);
      setRecs(Array.isArray(items) ? items : []);
    } catch (e) {
      setError(e.message || "Could not load recommendations.");
      setSession(null);
      setRecs([]);
    } finally {
      setLoading(false);
    }
  };

  if (!stats) return <div className="page">Loading…</div>;

  return (
    <div className="page fade-up dashboard-page">
      <section className="dashboard-stats-row">
        <div className="card dashboard-stat-card hover-lift">
          <span className="dashboard-stat-icon" aria-hidden>
            ⏱
          </span>
          <span className="dashboard-stat-value">{stats.total_minutes_spent}</span>
          <span className="dashboard-stat-label muted">Total minutes</span>
        </div>
        <div className="card dashboard-stat-card hover-lift">
          <span className="dashboard-stat-icon" aria-hidden>
            ✓
          </span>
          <span className="dashboard-stat-value">{stats.total_contents_completed}</span>
          <span className="dashboard-stat-label muted">Items completed</span>
        </div>
        <div className="card dashboard-stat-card hover-lift">
          <span className="dashboard-stat-icon" aria-hidden>
            🔥
          </span>
          <span className="dashboard-stat-value">{stats.current_streak_days}</span>
          <span className="dashboard-stat-label muted">Day streak</span>
        </div>
      </section>

      {cont && (
        <aside className="card dashboard-continue hover-lift">
          <div className="row-between" style={{ alignItems: "flex-start" }}>
            <div>
              <p className="muted" style={{ margin: 0, fontSize: "0.85rem" }}>
                Continue where you left off
              </p>
              <h3 className="dashboard-continue-title">{cont.content.title}</h3>
              <div className="progress-bar progress-bar--lg" style={{ marginTop: "0.5rem" }}>
                <div
                  className="progress-fill"
                  style={{ width: `${Math.min(100, cont.completion_percentage)}%` }}
                />
              </div>
              <p className="muted" style={{ margin: "0.35rem 0 0", fontSize: "0.85rem" }}>
                {cont.completion_percentage}% complete
              </p>
            </div>
            <Link className="btn" to="/progress">
              Continue
            </Link>
          </div>
        </aside>
      )}

      <section className="card dashboard-hero col">
        <h2 className="dashboard-hero-title">How many minutes do you have?</h2>
        <p className="muted dashboard-hero-sub">
          Set your time and mode — we&apos;ll surface content that fits.
        </p>

        <div className="dashboard-hero-time">
          <div className="dashboard-minute-stepper">
            <button
              type="button"
              className="dashboard-minute-stepper__btn"
              aria-label="Decrease minutes"
              onClick={() =>
                setForm((f) => ({
                  ...f,
                  available_minutes: clampMinutes(f.available_minutes - 1),
                }))
              }
            >
              −
            </button>
            <input
              type="number"
              className="dashboard-hero-input"
              min={1}
              max={MAX_MINUTES}
              inputMode="numeric"
              value={Math.min(form.available_minutes, MAX_MINUTES)}
              onChange={(e) =>
                setForm({
                  ...form,
                  available_minutes: clampMinutes(Number(e.target.value) || 1),
                })
              }
            />
            <button
              type="button"
              className="dashboard-minute-stepper__btn"
              aria-label="Increase minutes"
              onClick={() =>
                setForm((f) => ({
                  ...f,
                  available_minutes: clampMinutes(f.available_minutes + 1),
                }))
              }
            >
              +
            </button>
          </div>
          <span className="dashboard-hero-unit">min</span>
        </div>
        <input
          type="range"
          className="dashboard-hero-range"
          min={1}
          max={MAX_MINUTES}
          value={Math.min(form.available_minutes, MAX_MINUTES)}
          onChange={(e) =>
            setForm({ ...form, available_minutes: Number(e.target.value) })
          }
        />
        <div className="chips">
          {quickMins.map((m) => (
            <button
              key={m}
              type="button"
              className="chip"
              onClick={() => setForm({ ...form, available_minutes: m })}
            >
              {m} min
            </button>
          ))}
        </div>

        <p className="muted" style={{ margin: "0.75rem 0 0.25rem", fontSize: "0.9rem" }}>
          Mode
        </p>
        <div className="dashboard-mode-grid">
          {MODES.map((m) => (
            <button
              key={m.id}
              type="button"
              className={`btn mode-card ${m.className} ${form.goal === m.goal ? "mode-card--active" : "ghost"}`}
              onClick={() => setForm({ ...form, goal: m.goal })}
            >
              <span className="mode-card-label">{m.label}</span>
            </button>
          ))}
        </div>

        <label className="muted" style={{ fontSize: "0.85rem" }}>
          Difficulty
        </label>
        <div className="row" style={{ marginTop: "0.35rem" }}>
          {["beginner", "intermediate", "advanced"].map((d) => (
            <button
              key={d}
              type="button"
              className={`btn ${form.difficulty === d ? "" : "ghost"}`}
              onClick={() => setForm({ ...form, difficulty: d })}
            >
              {d}
            </button>
          ))}
        </div>

        <label className="muted" style={{ fontSize: "0.85rem", marginTop: "0.5rem" }}>
          Topic (optional)
        </label>
        <select
          value={form.selected_topic_id || ""}
          onChange={(e) =>
            setForm({ ...form, selected_topic_id: e.target.value ? Number(e.target.value) : null })
          }
        >
          <option value="">None</option>
          {topics.map((t) => (
            <option key={t.topic_id} value={t.topic_id}>
              {t.topic.name}
            </option>
          ))}
        </select>

        <label className="row" style={{ marginTop: "0.5rem" }}>
          <input
            type="checkbox"
            checked={form.is_offline}
            onChange={(e) => setForm({ ...form, is_offline: e.target.checked })}
          />
          <span className="muted">Offline only</span>
        </label>

        <button type="button" className="btn dashboard-hero-cta" onClick={createSession} disabled={loading}>
          {loading ? "Loading…" : "Get recommendations"}
        </button>
        {error && <p className="error">{error}</p>}

        {session && (
          <button
            type="button"
            className="btn ghost"
            onClick={async () => {
              try {
                await api.finishSession(session.id);
              } finally {
                setSession(null);
                setRecs([]);
              }
            }}
          >
            End session
          </button>
        )}
      </section>

      <div className="dashboard-recs-head row-between">
        <h2 className="dashboard-recs-title">Recommendations</h2>
        <Link to="/explore" className="btn ghost">
          Browse catalog →
        </Link>
      </div>
      <div className="grid">
        {recs.map((item) => (
          <ContentCard key={item.id} item={item} onSaved={() => {}} />
        ))}
      </div>
      {!loading && recs.length === 0 && !error && session && (
        <p className="muted">
          No recommendations yet — try a longer window or turn off &quot;Offline only&quot;.
        </p>
      )}

      <p className="muted" style={{ marginTop: "1.5rem", fontSize: "0.9rem" }}>
        For more content, open the{" "}
        <Link to="/explore">Explore</Link> page.
      </p>
    </div>
  );
}
