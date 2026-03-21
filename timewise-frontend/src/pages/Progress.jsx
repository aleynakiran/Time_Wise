import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import {
  Bar,
  BarChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { api } from "../api";
import {
  ProgressDonut,
  TypeBarChart,
  useProgressStats,
} from "../components/ProgressCharts";

export default function Progress() {
  const [items, setItems] = useState([]);
  const [weekly, setWeekly] = useState([]);
  const [achievements, setAchievements] = useState([]);

  const load = () => api.progress().then(setItems).catch(console.error);

  useEffect(() => {
    load();
    api.dashboardWeekly().then(setWeekly).catch(console.error);
    api.achievementsVitrine().then(setAchievements).catch(console.error);
  }, []);

  const stats = useProgressStats(items);

  const chartData = weekly.map((w) => ({
    label: w.label,
    minutes: w.minutes,
  }));

  return (
    <div className="page fade-up progress-page">
      <h2>Progress</h2>
      <p className="muted progress-tagline">
        Your wins and habits — a place to feel proud of how you spend your time.
      </p>

      <div className="card progress-weekly-card hover-lift">
        <h3 className="progress-section-title">Last 7 days (minutes)</h3>
        <p className="muted" style={{ fontSize: "0.85rem", marginTop: 0 }}>
          Sum of planned minutes from completed sessions, per day
        </p>
        {chartData.length > 0 ? (
          <div className="progress-recharts-wrap">
            <ResponsiveContainer width="100%" height={240}>
              <BarChart data={chartData} margin={{ top: 12, right: 8, left: -8, bottom: 0 }}>
                <XAxis dataKey="label" tick={{ fill: "var(--muted)", fontSize: 12 }} />
                <YAxis tick={{ fill: "var(--muted)", fontSize: 12 }} allowDecimals={false} />
                <Tooltip
                  contentStyle={{
                    background: "var(--card)",
                    border: "1px solid var(--border)",
                    borderRadius: "10px",
                  }}
                  formatter={(v) => [`${v} min`, "Time"]}
                />
                <Bar dataKey="minutes" fill="var(--accent)" radius={[6, 6, 0, 0]} maxBarSize={48} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        ) : (
          <p className="muted">Loading chart…</p>
        )}
      </div>

      {items.length > 0 && (
        <div className="card progress-summary-card">
          <h3 className="progress-summary-heading">Summary</h3>
          <div className="progress-summary-grid">
            <div className="progress-stat">
              <span className="progress-stat-value">{stats.total}</span>
              <span className="progress-stat-label muted">Tracked items</span>
            </div>
            <div className="progress-stat">
              <span className="progress-stat-value">{stats.avgPct}%</span>
              <span className="progress-stat-label muted">Avg. completion</span>
            </div>
            <div className="progress-stat">
              <span className="progress-stat-value accent">{stats.completed}</span>
              <span className="progress-stat-label muted">Completed</span>
            </div>
          </div>

          <div className="progress-charts-row">
            <div className="progress-chart-col">
              <h4 className="progress-chart-title">Breakdown</h4>
              <ProgressDonut
                completed={stats.completed}
                inProgress={stats.inProgress}
                notStarted={stats.notStarted}
              />
            </div>
            <div className="progress-chart-col progress-chart-col--wide">
              <TypeBarChart byType={stats.byType} />
            </div>
          </div>
        </div>
      )}

      <h3 className="progress-section-title" style={{ marginTop: "1.25rem" }}>
        Item progress
      </h3>
      <div className="grid">
        {items.map((p) => (
          <div className="card progress-item-card hover-lift" key={p.id}>
            <div className="row-between" style={{ marginBottom: "0.5rem" }}>
              <h3 style={{ margin: 0 }}>{p.content.title}</h3>
              {p.content.content_type && (
                <span className="chip">{p.content.content_type}</span>
              )}
            </div>
            <div className="progress-item-row">
              <div className="progress-bar progress-bar--lg" aria-hidden>
                <div
                  className="progress-fill"
                  style={{ width: `${Math.min(100, p.completion_percentage)}%` }}
                />
              </div>
              <span className="progress-pct">{p.completion_percentage}%</span>
            </div>
            <p className="muted" style={{ margin: "0.5rem 0 0", fontSize: "0.85rem" }}>
              {p.is_completed ? "Completed" : "In progress"}
            </p>
            <div className="row" style={{ marginTop: "0.75rem" }}>
              <button
                type="button"
                className="btn ghost"
                onClick={async () => {
                  await api.updateProgress(
                    p.content.id,
                    Math.min(100, p.completion_percentage + 25)
                  );
                  load();
                }}
              >
                +25%
              </button>
              <button
                type="button"
                className="btn"
                onClick={async () => {
                  await api.updateProgress(p.content.id, 100);
                  load();
                }}
              >
                Mark complete
              </button>
            </div>
          </div>
        ))}
      </div>

      {items.length === 0 && (
        <div className="card empty-state-card">
          <p className="muted" style={{ marginTop: 0 }}>
            No progress yet. Get recommendations from the dashboard or open content on{" "}
            <Link to="/explore">Explore</Link> and use &quot;Play here&quot; to record progress.
          </p>
          <Link className="btn" to="/explore">
            Go to Explore
          </Link>
        </div>
      )}

      <div className="card progress-achievements-card hover-lift">
        <h3 className="progress-section-title">Badge showcase</h3>
        <div className="achievement-vitrine-grid">
          {achievements.map((a) => (
            <div
              key={a.id}
              className={`achievement-tile ${a.earned ? "achievement-tile--earned" : "achievement-tile--locked"}`}
            >
              {!a.earned && <span className="achievement-tile-lock" aria-hidden>🔒</span>}
              <strong className="achievement-tile-title">{a.title}</strong>
              <p className="achievement-tile-desc muted">{a.description || "—"}</p>
              <div className="row" style={{ marginTop: "0.5rem", flexWrap: "wrap" }}>
                <span className="chip">{a.tier}</span>
                {a.xp_reward > 0 && <span className="chip">+{a.xp_reward} XP</span>}
              </div>
            </div>
          ))}
        </div>
        {achievements.length === 0 && (
          <p className="muted">Loading badges…</p>
        )}
      </div>
    </div>
  );
}
