import { useMemo } from "react";

function computeStats(items) {
  const total = items.length;
  if (!total) {
    return {
      total: 0,
      completed: 0,
      inProgress: 0,
      notStarted: 0,
      avgPct: 0,
      byType: [],
    };
  }
  let completed = 0;
  let inProgress = 0;
  let notStarted = 0;
  let sumPct = 0;
  const typeMap = new Map();

  for (const p of items) {
    const pct = p.completion_percentage ?? 0;
    sumPct += pct;
    const done = p.is_completed || pct >= 100;
    if (done) completed += 1;
    else if (pct > 0) inProgress += 1;
    else notStarted += 1;

    const t = p.content?.content_type || "unknown";
    typeMap.set(t, (typeMap.get(t) || 0) + 1);
  }

  const byType = [...typeMap.entries()]
    .map(([type, count]) => ({ type, count }))
    .sort((a, b) => b.count - a.count);

  return {
    total,
    completed,
    inProgress,
    notStarted,
    avgPct: Math.round(sumPct / total),
    byType,
  };
}

/** Donut chart — conic-gradient: completed / in progress / not started */
export function ProgressDonut({ completed, inProgress, notStarted }) {
  const total = completed + inProgress + notStarted;
  if (total === 0) {
    return (
      <div className="progress-donut-empty muted" style={{ fontSize: "0.9rem" }}>
        No data
      </div>
    );
  }

  const a1 = (completed / total) * 360;
  const a2 = ((completed + inProgress) / total) * 360;
  const bg = `conic-gradient(
    from -90deg,
    var(--chart-done) 0deg ${a1}deg,
    var(--chart-doing) ${a1}deg ${a2}deg,
    var(--chart-todo) ${a2}deg 360deg
  )`;

  return (
    <div className="progress-donut-wrap">
      <div className="progress-donut-ring" style={{ background: bg }}>
        <div className="progress-donut-hole">
          <span className="progress-donut-center">{total}</span>
          <span className="progress-donut-center-sub muted">items</span>
        </div>
      </div>
      <div className="progress-donut-legend">
        <span>
          <i className="dot dot--done" /> Done ({completed})
        </span>
        <span>
          <i className="dot dot--doing" /> In progress ({inProgress})
        </span>
        <span>
          <i className="dot dot--todo" /> Not started ({notStarted})
        </span>
      </div>
    </div>
  );
}

export function TypeBarChart({ byType }) {
  if (!byType.length) return null;
  const max = Math.max(...byType.map((x) => x.count), 1);
  const sum = byType.reduce((s, x) => s + x.count, 0);
  return (
    <div className="progress-type-bars">
      <h4 className="progress-chart-title">By content type</h4>
      {byType.map(({ type, count }, i) => {
        const pctOfTotal = sum ? Math.round((count / sum) * 100) : 0;
        const label = `${type}: ${count} items (${pctOfTotal}% share)`;
        return (
          <div key={type} className="progress-type-row">
            <span className="progress-type-label" title={type}>
              {type}
            </span>
            <div className="progress-type-track" title={label}>
              <div
                className={`progress-type-fill progress-type-fill--${i % 5}`}
                style={{ width: `${(count / max) * 100}%` }}
              />
            </div>
            <span className="progress-type-count" title={label}>
              {count}
            </span>
          </div>
        );
      })}
    </div>
  );
}

export function useProgressStats(items) {
  return useMemo(() => computeStats(items), [items]);
}
