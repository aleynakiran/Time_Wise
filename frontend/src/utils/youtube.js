/**
 * Extract 11-char YouTube video id from common URL shapes.
 * Returns null if not a recognizable YouTube watch/embed/short URL.
 */
export function tryParseYouTubeVideoId(url) {
  if (!url || typeof url !== "string") return null;
  const trimmed = url.trim();
  try {
    const u = new URL(trimmed.startsWith("http") ? trimmed : `https://${trimmed}`);
    const host = u.hostname.replace(/^www\./, "").toLowerCase();

    if (host === "youtu.be") {
      const id = u.pathname.replace(/^\//, "").split("/")[0];
      return id && /^[a-zA-Z0-9_-]{11}$/.test(id) ? id : null;
    }

    if (
      host === "youtube.com" ||
      host === "m.youtube.com" ||
      host === "music.youtube.com"
    ) {
      if (u.pathname === "/watch" || u.pathname.startsWith("/watch/")) {
        const v = u.searchParams.get("v");
        if (v && /^[a-zA-Z0-9_-]{11}$/.test(v)) return v;
      }
      const embed = u.pathname.match(/^\/embed\/([a-zA-Z0-9_-]{11})/);
      if (embed) return embed[1];
      const shorts = u.pathname.match(/^\/shorts\/([a-zA-Z0-9_-]{11})/);
      if (shorts) return shorts[1];
      const live = u.pathname.match(/^\/live\/([a-zA-Z0-9_-]{11})/);
      if (live) return live[1];
    }
  } catch {
    return null;
  }
  return null;
}

export function isYouTubeUrl(url) {
  return tryParseYouTubeVideoId(url) != null;
}
