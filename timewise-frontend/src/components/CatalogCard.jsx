import { useState } from "react";
import { api } from "../api";
import YouTubePlayer from "./YouTubePlayer";
import { tryParseYouTubeVideoId } from "../utils/youtube";

function openExternalContent(content) {
  if (content.content_type === "game" && content.embedded_html) {
    const popup = window.open("", "_blank");
    popup.document.write(content.embedded_html);
    popup.document.close();
    return;
  }
  if (content.content_type === "book" && content.ebook_url) {
    window.open(content.ebook_url, "_blank");
    return;
  }
  if (content.content_type === "music_playlist" && content.playlist_url) {
    window.open(content.playlist_url, "_blank");
    return;
  }
  if (content.url) window.open(content.url, "_blank");
}

export default function CatalogCard({ content, onBookmark }) {
  const youtubeId = content.url ? tryParseYouTubeVideoId(content.url) : null;
  const [showYoutube, setShowYoutube] = useState(false);

  return (
    <div className="card catalog-card hover-lift">
      <span className="catalog-duration-badge" title="Duration">
        {content.duration_minutes} min
      </span>
      <div className="row-between catalog-card-head">
        <h3 className="catalog-card-title">{content.title}</h3>
      </div>
      <p className="catalog-card-desc">{content.description || ""}</p>
      <div className="chips">
        <span className="chip">{content.content_type}</span>
        <span className="chip">{content.difficulty}</span>
      </div>
      <div className="row catalog-card-actions">
        {youtubeId ? (
          <>
            <button
              type="button"
              className="btn"
              onClick={() => setShowYoutube((s) => !s)}
            >
              {showYoutube ? "Hide" : "Play here"}
            </button>
            <button type="button" className="btn ghost" onClick={() => openExternalContent(content)}>
              New tab
            </button>
          </>
        ) : (
          <button type="button" className="btn" onClick={() => openExternalContent(content)}>
            Open
          </button>
        )}
        <button
          type="button"
          className="btn ghost"
          onClick={async () => {
            await api.addBookmark(content.id);
            onBookmark?.();
          }}
        >
          Save
        </button>
      </div>
      {youtubeId && showYoutube && (
        <YouTubePlayer videoId={youtubeId} contentId={content.id} />
      )}
    </div>
  );
}
