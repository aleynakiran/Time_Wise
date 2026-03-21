import { useCallback, useEffect, useRef, useState } from "react";
import { api } from "../api";
import { loadYouTubeIframeAPI } from "../lib/youtubeIframeApi";

const POLL_MS = 4000;
const MIN_DELTA = 5;

/**
 * Inline YouTube player with IFrame API — reports progress to backend.
 */
export default function YouTubePlayer({ videoId, contentId }) {
  const containerRef = useRef(null);
  const playerRef = useRef(null);
  const pollRef = useRef(null);
  const lastSentRef = useRef(-1);
  const [loadError, setLoadError] = useState(null);
  const [apiError, setApiError] = useState(null);

  const sendProgress = useCallback(
    async (pct) => {
      const rounded = Math.min(100, Math.max(0, Math.round(pct)));
      if (rounded === 100) {
        if (lastSentRef.current >= 100) return;
      } else {
        if (lastSentRef.current >= 0 && rounded - lastSentRef.current < MIN_DELTA) {
          return;
        }
      }
      lastSentRef.current = rounded;
      try {
        await api.updateProgress(contentId, rounded);
        setApiError(null);
      } catch (e) {
        setApiError(e.message || "Could not save progress");
      }
    },
    [contentId]
  );

  const clearPoll = () => {
    if (pollRef.current) {
      clearInterval(pollRef.current);
      pollRef.current = null;
    }
  };

  useEffect(() => {
    let cancelled = false;
    const container = containerRef.current;
    if (!container || !videoId || !contentId) return undefined;

    setLoadError(null);
    lastSentRef.current = -1;

    (async () => {
      try {
        await loadYouTubeIframeAPI();
      } catch {
        if (!cancelled) setLoadError("Could not load YouTube API.");
        return;
      }
      if (cancelled || !window.YT?.Player) {
        if (!cancelled) setLoadError("YouTube API is not ready.");
        return;
      }

      const YT = window.YT;
      const onStateChange = (e) => {
        if (e.data === YT.PlayerState.PLAYING) {
          clearPoll();
          pollRef.current = setInterval(() => {
            const p = playerRef.current;
            if (!p || !p.getDuration || !p.getCurrentTime) return;
            const dur = p.getDuration();
            const cur = p.getCurrentTime();
            if (!dur || dur <= 0) return;
            const pct = (cur / dur) * 100;
            sendProgress(pct);
          }, POLL_MS);
        } else {
          clearPoll();
        }
        if (e.data === YT.PlayerState.ENDED) {
          sendProgress(100);
        }
      };

      const onError = (e) => {
        const codes = {
          2: "Invalid parameter",
          5: "HTML5 playback error",
          100: "Video not found or private",
          101: "Embedding disabled for this video",
          150: "Embedding disabled for this video",
        };
        const msg = codes[e.data] || `Player error (${e.data})`;
        setLoadError(msg);
        clearPoll();
      };

      playerRef.current = new YT.Player(container, {
        videoId,
        width: "100%",
        height: "100%",
        playerVars: {
          playsinline: 1,
          rel: 0,
          modestbranding: 1,
        },
        events: {
          onReady: () => {
            if (cancelled) return;
            setLoadError(null);
          },
          onStateChange,
          onError,
        },
      });
    })();

    return () => {
      cancelled = true;
      clearPoll();
      try {
        playerRef.current?.destroy?.();
      } catch {
        /* ignore */
      }
      playerRef.current = null;
    };
  }, [videoId, contentId, sendProgress]);

  return (
    <div className="youtube-player-block">
      <p className="muted" style={{ margin: "0 0 0.5rem", fontSize: "0.85rem" }}>
        In-app playback — progress is saved. Some videos may block embedding.
      </p>
      <div className="youtube-player-wrap">
        <div ref={containerRef} className="youtube-player-mount" />
      </div>
      {loadError && (
        <p className="error" style={{ marginTop: "0.5rem" }}>
          {loadError} — try &quot;Open in new tab&quot; to watch.
        </p>
      )}
      {apiError && (
        <p className="error" style={{ marginTop: "0.35rem" }}>
          {apiError}
        </p>
      )}
    </div>
  );
}
