import { useEffect, useMemo, useState } from "react";
import { Link } from "react-router-dom";
import { api } from "../api";
import { contentMatchesGoal, goalsForContentType } from "../utils/goalContentMap";

const MAX_MINUTE_OPTIONS = [
  { value: "", label: "Any duration" },
  { value: 15, label: "≤ 15 min" },
  { value: 30, label: "≤ 30 min" },
  { value: 45, label: "≤ 45 min" },
  { value: 60, label: "≤ 60 min" },
  { value: 90, label: "≤ 90 min" },
  { value: 120, label: "≤ 120 min" },
  { value: 180, label: "≤ 180 min" },
  { value: 240, label: "≤ 240 min" },
];

const GOAL_FILTER_OPTIONS = [
  { value: "", label: "All focus modes" },
  { value: "learn", label: "Learn" },
  { value: "focus", label: "Focus" },
  { value: "relax", label: "Relax" },
  { value: "productive", label: "Productive" },
];

function TrashIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" aria-hidden>
      <path d="M3 6h18M8 6V4h8v2M19 6v14a2 2 0 01-2 2H7a2 2 0 01-2-2V6M10 11v6M14 11v6" />
    </svg>
  );
}

export default function Bookmarks() {
  const [items, setItems] = useState([]);
  const [maxMinutes, setMaxMinutes] = useState("");
  const [goalFilter, setGoalFilter] = useState("");
  const [search, setSearch] = useState("");

  const load = () => api.bookmarks().then(setItems).catch(console.error);
  useEffect(() => {
    load();
  }, []);

  const filtered = useMemo(() => {
    const max = maxMinutes === "" ? null : Number(maxMinutes);
    const goal = goalFilter === "" ? null : goalFilter;
    const q = search.trim().toLowerCase();

    return items.filter((b) => {
      const c = b.content;
      if (q && !(c.title || "").toLowerCase().includes(q)) return false;
      if (max != null && c.duration_minutes > max) return false;
      if (goal != null && !contentMatchesGoal(c.content_type, goal)) {
        return false;
      }
      return true;
    });
  }, [items, maxMinutes, goalFilter, search]);

  const hasFilters =
    maxMinutes !== "" || goalFilter !== "" || search.trim() !== "";

  return (
    <div className="page fade-up bookmarks-page">
      <h2>Bookmarks</h2>

      <div className="card bookmarks-filters">
        <div className="row" style={{ flexWrap: "wrap", gap: "0.75rem" }}>
          <label className="col" style={{ minWidth: "200px", flex: "1 1 200px" }}>
            <span className="muted" style={{ fontSize: "0.85rem" }}>
              Search (title)
            </span>
            <input
              type="search"
              placeholder="Search by title…"
              value={search}
              onChange={(e) => setSearch(e.target.value)}
            />
          </label>
          <label className="col" style={{ minWidth: "160px", flex: "1 1 160px" }}>
            <span className="muted" style={{ fontSize: "0.85rem" }}>
              Max duration
            </span>
            <select
              value={maxMinutes}
              onChange={(e) =>
                setMaxMinutes(e.target.value === "" ? "" : e.target.value)
              }
            >
              {MAX_MINUTE_OPTIONS.map((o) => (
                <option key={String(o.value)} value={o.value}>
                  {o.label}
                </option>
              ))}
            </select>
          </label>
          <label className="col" style={{ minWidth: "180px", flex: "1 1 180px" }}>
            <span className="muted" style={{ fontSize: "0.85rem" }}>
              Focus mode
            </span>
            <select value={goalFilter} onChange={(e) => setGoalFilter(e.target.value)}>
              {GOAL_FILTER_OPTIONS.map((o) => (
                <option key={o.value || "all"} value={o.value}>
                  {o.label}
                </option>
              ))}
            </select>
          </label>
          {hasFilters && (
            <button
              type="button"
              className="btn ghost"
              style={{ alignSelf: "flex-end" }}
              onClick={() => {
                setMaxMinutes("");
                setGoalFilter("");
                setSearch("");
              }}
            >
              Clear filters
            </button>
          )}
        </div>
        {hasFilters && (
          <p className="muted" style={{ margin: "0.75rem 0 0", fontSize: "0.9rem" }}>
            Showing {filtered.length} of {items.length}
          </p>
        )}
      </div>

      <div className="grid">
        {filtered.map((b) => {
          const goals = goalsForContentType(b.content?.content_type);
          return (
            <div className="card bookmark-card hover-lift" key={b.id}>
              <button
                type="button"
                className="bookmark-remove-btn"
                title="Remove"
                aria-label="Remove from bookmarks"
                onClick={async () => {
                  await api.removeBookmark(b.content.id);
                  load();
                }}
              >
                <TrashIcon />
              </button>
              <div className="row-between" style={{ marginBottom: "0.5rem", paddingRight: "2rem" }}>
                <span className="chip">{b.content.duration_minutes} min</span>
                <div className="chips" style={{ justifyContent: "flex-end" }}>
                  {goals.length > 0 ? (
                    goals.map((g) => (
                      <span className="chip" key={g}>
                        {g}
                      </span>
                    ))
                  ) : (
                    <span className="chip">{b.content.content_type}</span>
                  )}
                </div>
              </div>
              <h3>{b.content.title}</h3>
              <p>{b.content.description}</p>
            </div>
          );
        })}
      </div>

      {items.length === 0 && (
        <div className="card empty-state-card">
          <p className="muted" style={{ marginTop: 0 }}>
            You haven&apos;t saved anything yet — want to explore?
          </p>
          <Link className="btn" to="/explore">
            Go to Explore
          </Link>
        </div>
      )}
      {items.length > 0 && filtered.length === 0 && (
        <p className="muted">
          No items match these filters. Adjust or clear them.
        </p>
      )}
    </div>
  );
}
