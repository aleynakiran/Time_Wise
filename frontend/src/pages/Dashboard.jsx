import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api";
import ContentCard from "../components/ContentCard";
import { fireConfettiBurst } from "../lib/confetti";

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
  const [sessionEarnings, setSessionEarnings] = useState({ xp: 0, minutes: 0, completed: 0 });
  const [rewardBurst, setRewardBurst] = useState(null);
  const [showSessionEndModal, setShowSessionEndModal] = useState(false);
  const [sessionEndSnapshot, setSessionEndSnapshot] = useState({ xp: 0, minutes: 0, completed: 0 });
  const [goals, setGoals] = useState({ weeklyMinutes: 300, weeklyCompleted: 10 });
  const [form, setForm] = useState({
    available_minutes: 25,
    goal: "learn",
  });

  useEffect(() => {
    api.dashboardStats().then(setStats).catch(console.error);
    api.dashboardContinue().then(setCont).catch(() => setCont(null));
  }, []);

  useEffect(() => {
    try {
      const raw = localStorage.getItem("tw_weekly_goals");
      if (!raw) return;
      const parsed = JSON.parse(raw);
      if (Number.isFinite(parsed?.weeklyMinutes) && Number.isFinite(parsed?.weeklyCompleted)) {
        setGoals({
          weeklyMinutes: Math.max(60, Math.min(1200, Number(parsed.weeklyMinutes))),
          weeklyCompleted: Math.max(1, Math.min(200, Number(parsed.weeklyCompleted))),
        });
      }
    } catch {
      // Keep defaults if local storage is unavailable or malformed.
    }
  }, []);

  useEffect(() => {
    localStorage.setItem("tw_weekly_goals", JSON.stringify(goals));
  }, [goals]);

  useEffect(() => {
    if (!rewardBurst) return undefined;
    fireConfettiBurst();
    const t = setTimeout(() => setRewardBurst(null), 4000);
    return () => clearTimeout(t);
  }, [rewardBurst]);

  useEffect(() => {
    if (!showSessionEndModal) return undefined;
    fireConfettiBurst();
    const t = setTimeout(() => setShowSessionEndModal(false), 4000);
    return () => clearTimeout(t);
  }, [showSessionEndModal]);

  const handleProgressAward = (award) => {
    if (!award?.newlyCompleted) return;
    const gainedMinutes = Number(award.gainedMinutes || 0);
    const gainedXp = Number(award.gainedXp || 0);

    setStats((prev) => {
      if (!prev) return prev;
      const total_xp = prev.total_xp + gainedXp;
      const current_level = Math.max(1, Math.floor(total_xp / 100) + 1);
      return {
        ...prev,
        total_minutes_spent: prev.total_minutes_spent + gainedMinutes,
        total_xp,
        current_level,
        total_contents_completed: prev.total_contents_completed + 1,
      };
    });

    setSessionEarnings((prev) => ({
      xp: prev.xp + gainedXp,
      minutes: prev.minutes + gainedMinutes,
      completed: prev.completed + 1,
    }));

    setRewardBurst({
      id: Date.now(),
      gainedMinutes,
      gainedXp,
    });
  };

  const createSession = async () => {
    setError("");
    setLoading(true);
    setRecs([]);
    setSessionEarnings({ xp: 0, minutes: 0, completed: 0 });
    setRewardBurst(null);
    try {
      const s = await api.createSession({
        ...form,
        available_minutes: Math.min(form.available_minutes, MAX_MINUTES),
      });
      setSession(s);
      const items = await api.recommendations(s.id);
      const next = Array.isArray(items) ? items : [];
      setRecs(next);
    } catch (e) {
      setError(e.message || "Could not load recommendations.");
      setSession(null);
      setRecs([]);
    } finally {
      setLoading(false);
    }
  };

  if (!stats) return <div className="page">Loading…</div>;

  const minutesGoalPct = Math.min(100, Math.round((stats.total_minutes_spent / goals.weeklyMinutes) * 100));
  const completedGoalPct = Math.min(100, Math.round((stats.total_contents_completed / goals.weeklyCompleted) * 100));
  const goalLeague = minutesGoalPct >= 100 && completedGoalPct >= 100 ? "gold" : minutesGoalPct >= 70 ? "silver" : "bronze";
  const flamesCount = Math.max(1, Math.min(5, Math.ceil((minutesGoalPct + completedGoalPct) / 40)));

  return (
    <div className="page fade-up dashboard-page">
      {rewardBurst && (
        <div key={rewardBurst.id} className="dashboard-reward-pop" role="status" aria-live="polite">
          <span className="dashboard-reward-pop__spark" aria-hidden>
            ✨
          </span>
          <strong>Completed!</strong>
          <span>
            +{rewardBurst.gainedXp} XP · +{rewardBurst.gainedMinutes} min
          </span>
        </div>
      )}

      {showSessionEndModal && (
        <div
          className="dashboard-session-modal-overlay"
          role="dialog"
          aria-modal="true"
          aria-labelledby="session-reward-title"
        >
          <div className="dashboard-session-modal">
            <h2 id="session-reward-title" className="dashboard-session-modal__title">
              Session rewards
            </h2>
            <p className="dashboard-session-modal__sub">
              Here’s what you earned in this session (finished videos only).
            </p>
            <div className="dashboard-session-modal__stats">
              <div>
                <span className="muted">XP</span>
                <strong>+{sessionEndSnapshot.xp}</strong>
              </div>
              <div>
                <span className="muted">Minutes</span>
                <strong>+{sessionEndSnapshot.minutes}</strong>
              </div>
              <div>
                <span className="muted">Items completed</span>
                <strong>{sessionEndSnapshot.completed}</strong>
              </div>
            </div>
            <button type="button" className="btn dashboard-session-modal__btn" onClick={() => setShowSessionEndModal(false)}>
              Nice!
            </button>
          </div>
        </div>
      )}

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
        <div className="card dashboard-stat-card hover-lift">
          <span className="dashboard-stat-icon" aria-hidden>
            ✨
          </span>
          <span className="dashboard-stat-value">{stats.total_xp}</span>
          <span className="dashboard-stat-label muted">Total XP</span>
        </div>
        <div className="card dashboard-goal-card hover-lift">
          <div className="row-between">
            <div className="dashboard-goal-head">
              <span className="dashboard-goal-icon" aria-hidden>🎯</span>
              <strong className="dashboard-goal-title">Weekly goals</strong>
            </div>
            <div className="chips dashboard-goal-chips">
              <span className="chip">M: {goals.weeklyMinutes}</span>
              <span className="chip">C: {goals.weeklyCompleted}</span>
            </div>
          </div>
          <div className="dashboard-goal-streakline">
            <div className={`dashboard-goal-league dashboard-goal-league--${goalLeague}`}>
              {goalLeague.toUpperCase()} LEAGUE
            </div>
            <div className="dashboard-goal-xp">
              <span role="img" aria-label="sparkles">✨</span> Level {stats.current_level} · {stats.total_xp} XP earned
            </div>
          </div>
          <div className="dashboard-goal-flames" aria-label={`Weekly streak flames ${flamesCount} of 5`}>
            <span className="dashboard-goal-flames__label">Weekly streak</span>
            <div className="dashboard-goal-flames__icons" aria-hidden>
              {Array.from({ length: 5 }).map((_, idx) => (
                <span
                  key={idx}
                  className={`dashboard-goal-flame ${idx < flamesCount ? "is-on" : ""}`}
                >
                  🔥
                </span>
              ))}
            </div>
          </div>
          <div className="dashboard-goal-inputs">
            <label>
              <span className="muted">Minutes target</span>
              <input
                aria-label="Weekly minutes target"
                type="number"
                min={60}
                max={1200}
                value={goals.weeklyMinutes}
                onChange={(e) =>
                  setGoals((g) => ({
                    ...g,
                    weeklyMinutes: Math.max(60, Math.min(1200, Number(e.target.value) || 60)),
                  }))
                }
              />
            </label>
            <label>
              <span className="muted">Completed target</span>
              <input
                aria-label="Weekly completed items target"
                type="number"
                min={1}
                max={200}
                value={goals.weeklyCompleted}
                onChange={(e) =>
                  setGoals((g) => ({
                    ...g,
                    weeklyCompleted: Math.max(1, Math.min(200, Number(e.target.value) || 1)),
                  }))
                }
              />
            </label>
          </div>
          <div className="dashboard-goal-meters">
            <div>
              <div className="row-between">
                <span className="muted">Minutes progress</span>
                <span className="muted">
                  {stats.total_minutes_spent}/{goals.weeklyMinutes} ({minutesGoalPct}%)
                </span>
              </div>
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: `${minutesGoalPct}%` }} />
              </div>
            </div>
            <div>
              <div className="row-between">
                <span className="muted">Completed progress</span>
                <span className="muted">
                  {stats.total_contents_completed}/{goals.weeklyCompleted} ({completedGoalPct}%)
                </span>
              </div>
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: `${completedGoalPct}%` }} />
              </div>
            </div>
          </div>
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

        <div className="dashboard-hero-actions">
          <button
            type="button"
            className="btn dashboard-hero-cta"
            onClick={createSession}
            disabled={loading}
            aria-label="Create a new recommendation session"
          >
            {loading ? "Loading…" : "Get recommendations"}
          </button>
          {session && (
            <button
              type="button"
              className="btn ghost dashboard-hero-end"
              onClick={async () => {
                const snap = { ...sessionEarnings };
                const sid = session.id;
                try {
                  if (sid) await api.finishSession(sid);
                } catch (e) {
                  console.warn(e);
                } finally {
                  setSessionEndSnapshot(snap);
                  setShowSessionEndModal(true);
                  setSession(null);
                  setRecs([]);
                }
              }}
            >
              End session
            </button>
          )}
        </div>
        {error && <p className="error">{error}</p>}
      </section>

      <div className="dashboard-recs-head row-between">
        <h2 className="dashboard-recs-title">Recommendations</h2>
        <Link to="/explore" className="btn ghost">
          Browse catalog →
        </Link>
      </div>
      <div className="grid">
        {recs.map((item) => (
          <ContentCard key={item.id} item={item} onSaved={() => {}} onProgressAward={handleProgressAward} />
        ))}
      </div>
      {!loading && recs.length === 0 && !error && session && (
        <p className="muted">
          No recommendations yet — try a longer time window or a different mode.
        </p>
      )}

      <p className="muted" style={{ marginTop: "1.5rem", fontSize: "0.9rem" }}>
        For more content, open the{" "}
        <Link to="/explore">Explore</Link> page.
      </p>
    </div>
  );
}
