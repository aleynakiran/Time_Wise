/**
 * Loads the YouTube IFrame API once; resolves when window.YT.Player is available.
 */
let loadPromise = null;

export function loadYouTubeIframeAPI() {
  if (typeof window === "undefined") {
    return Promise.resolve();
  }
  if (window.YT && window.YT.Player) {
    return Promise.resolve();
  }
  if (!loadPromise) {
    loadPromise = new Promise((resolve) => {
      const finish = () => {
        if (window.YT && window.YT.Player) resolve();
      };
      const prev = window.onYouTubeIframeAPIReady;
      window.onYouTubeIframeAPIReady = function () {
        try {
          prev?.();
        } finally {
          finish();
        }
      };
      const tag = document.createElement("script");
      tag.src = "https://www.youtube.com/iframe_api";
      tag.async = true;
      document.head.appendChild(tag);
    });
  }
  return loadPromise;
}
