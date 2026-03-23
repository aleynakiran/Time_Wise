import { useState } from "react";
import { api } from "../api";
import YouTubePlayer from "./YouTubePlayer";
import { tryParseYouTubeVideoId } from "../utils/youtube";

export default function ContentCard({ item, onSaved }) {
  const { content } = item;
  const youtubeId = content.url ? tryParseYouTubeVideoId(content.url) : null;
  const [showYoutube, setShowYoutube] = useState(false);

  const openContent = () => {
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
  };

  return (
    <div className="card content-card">
      <div className="row-between">
        <h3>{content.title}</h3>
        <span className="badge">{content.difficulty}</span>
      </div>
      <p>{content.description || ""}</p>
      <div className="chips">
        <span className="chip">{content.content_type}</span>
        <span className="chip">{content.duration_minutes} min</span>
        <span className="chip">Score {Math.round(item.score)}%</span>
        {youtubeId && <span className="chip">YouTube</span>}
      </div>
      <p className="reason">{item.reason_text || item.reason_template || ""}</p>
      <div className="row">
        {youtubeId ? (
          <>
            <button
              type="button"
              className="btn"
              onClick={() => setShowYoutube((s) => !s)}
              aria-label={showYoutube ? `Hide player for ${content.title}` : `Play ${content.title} here`}
            >
              {showYoutube ? "Hide player" : "Play here"}
            </button>
            <button
              type="button"
              className="btn ghost"
              onClick={openContent}
              aria-label={`Open ${content.title} in a new tab`}
            >
              Open in new tab
            </button>
          </>
        ) : (
          <button type="button" className="btn" onClick={openContent} aria-label={`Open ${content.title}`}>
            Open
          </button>
        )}
        <button
          type="button"
          className="btn ghost"
          onClick={async () => {
            await api.addBookmark(content.id);
            onSaved?.();
          }}
          aria-label={`Save ${content.title} to bookmarks`}
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
