function resolveApiBase() {
  const fromEnv = import.meta.env.VITE_API_URL;
  if (fromEnv && String(fromEnv).trim() !== "") {
    return String(fromEnv).replace(/\/$/, "");
  }
  if (import.meta.env.DEV) {
    return "/api";
  }
  return "http://localhost:8001";
}

const API_BASE = resolveApiBase();

export function getToken() {
  return localStorage.getItem("tw_token");
}

function friendlyNetworkError(err) {
  const msg = String(err?.message || err || "");
  const lower = msg.toLowerCase();
  if (
    lower === "load failed" ||
    lower === "failed to fetch" ||
    lower.includes("networkerror") ||
    lower.includes("network error") ||
    lower === "network request failed"
  ) {
    return "Could not reach the API. Is the backend running? Check VITE_API_URL (default http://localhost:8001).";
  }
  return msg || "Network error";
}

async function request(path, options = {}) {
  const token = getToken();
  const headers = { "Content-Type": "application/json", ...(options.headers || {}) };
  if (token) headers.Authorization = `Bearer ${token}`;

  let res;
  try {
    res = await fetch(`${API_BASE}${path}`, { ...options, headers });
  } catch (e) {
    throw new Error(friendlyNetworkError(e));
  }
  if (!res.ok) {
    const data = await res.json().catch(() => ({}));
    const detail = data?.detail;

    let message = "Request failed";

    // FastAPI validation errors usually return:
    // { detail: [{ loc: [...], msg: "...", type: "..."}] }
    if (typeof detail === "string") {
      message = detail;
    } else if (Array.isArray(detail)) {
      const parts = [];

      for (const d of detail) {
        if (typeof d === "string") {
          parts.push(d);
          continue;
        }

        const loc = Array.isArray(d?.loc) ? d.loc : [];
        const type = d?.type || "";

        // Password min_length validation
        if (loc.includes("password") && type === "string_too_short") {
          const minLen = d?.ctx?.min_length;
          parts.push(`Şifre en az ${minLen ?? 6} karakter olmalıdır.`);
          continue;
        }

        if (d?.msg) parts.push(d.msg);
      }

      message = parts.length ? parts.join(", ") : message;
    } else if (detail && typeof detail === "object") {
      message = detail?.msg || detail?.message || JSON.stringify(detail);
    }

    throw new Error(message);
  }
  if (res.status === 204) return null;
  const text = await res.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    throw new Error("Invalid response from server.");
  }
}

function buildQuery(params = {}) {
  const q = new URLSearchParams();
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== "") q.set(k, String(v));
  });
  const s = q.toString();
  return s ? `?${s}` : "";
}

export const api = {
  register: (payload) => request("/auth/register", { method: "POST", body: JSON.stringify(payload) }),
  login: (payload) => request("/auth/login", { method: "POST", body: JSON.stringify(payload) }),
  me: () => request("/auth/me"),
  topics: () => request("/topics"),
  completeOnboarding: (topic_slugs) =>
    request("/onboarding/complete", { method: "POST", body: JSON.stringify({ topic_slugs }) }),
  getUserTopics: () => request("/users/me/topics"),
  updateUserTopics: (payload) => request("/users/me/topics", { method: "POST", body: JSON.stringify(payload) }),
  createSession: (payload) => request("/sessions", { method: "POST", body: JSON.stringify(payload) }),
  sessions: () => request("/sessions"),
  recommendations: (id) => request(`/sessions/${id}/recommendations`),
  finishSession: (id) => request(`/sessions/${id}/complete`, { method: "PATCH" }),
  bookmarks: () => request("/bookmarks"),
  addBookmark: (id) => request(`/bookmarks/${id}`, { method: "POST" }),
  removeBookmark: (id) => request(`/bookmarks/${id}`, { method: "DELETE" }),
  progress: () => request("/progress"),
  updateProgress: (id, completion_percentage) =>
    request(`/progress/${id}`, { method: "PUT", body: JSON.stringify({ completion_percentage }) }),
  dashboard: () => request("/dashboard"),
  dashboardStats: () => request("/dashboard/stats"),
  dashboardAchievements: () => request("/dashboard/achievements"),
  dashboardContinue: () => request("/dashboard/continue"),
  dashboardQueue: () => request("/dashboard/queue"),
  dashboardWeekly: () => request("/dashboard/weekly-activity"),
  contents: (params) => request(`/contents${buildQuery(params)}`),
  achievementsVitrine: () => request("/achievements/vitrine"),
};
