import { useEffect, useState } from "react";
import CatalogCard from "../components/CatalogCard";
import { api } from "../api";

function HorizontalSection({ title, subtitle, children }) {
  return (
    <section className="explore-section">
      <div className="explore-section-head">
        <h3 className="explore-section-title">{title}</h3>
        {subtitle && <p className="muted explore-section-sub">{subtitle}</p>}
      </div>
      <div className="catalog-scroll">{children}</div>
    </section>
  );
}

export default function Explore() {
  const [forYou, setForYou] = useState([]);
  const [podcasts, setPodcasts] = useState([]);
  const [articles, setArticles] = useState([]);
  const [err, setErr] = useState("");

  const load = () => {
    setErr("");
    Promise.all([
      api.contents({ sort: "popular", limit: 14 }),
      api.contents({ content_type: "podcast", sort: "popular", limit: 14 }),
      api.contents({ content_type: "article", max_duration: 15, sort: "recent", limit: 14 }),
    ])
      .then(([a, b, c]) => {
        setForYou(a);
        setPodcasts(b);
        setArticles(c);
      })
      .catch((e) => setErr(e.message || "Failed to load"));
  };

  useEffect(() => {
    load();
  }, []);

  return (
    <div className="page fade-up explore-page">
      <h2>Explore</h2>
      <p className="muted explore-intro">
        Content grouped by category — scroll rows horizontally.
      </p>
      {err && <p className="error">{err}</p>}

      <HorizontalSection
        title="Picked for you"
        subtitle="Popular and fresh picks"
      >
        {forYou.map((c) => (
          <CatalogCard key={c.id} content={c} onBookmark={load} />
        ))}
      </HorizontalSection>

      <HorizontalSection title="Popular podcasts" subtitle="Listen and learn">
        {podcasts.map((c) => (
          <CatalogCard key={c.id} content={c} onBookmark={load} />
        ))}
      </HorizontalSection>

      <HorizontalSection
        title="Short reads"
        subtitle="Articles under ~15 min"
      >
        {articles.map((c) => (
          <CatalogCard key={c.id} content={c} onBookmark={load} />
        ))}
      </HorizontalSection>

      {!err && forYou.length === 0 && podcasts.length === 0 && articles.length === 0 && (
        <p className="muted">No catalog data yet.</p>
      )}
    </div>
  );
}
