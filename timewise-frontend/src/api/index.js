const API_BASE = "http://localhost:8001";

export function getToken() {
  return localStorage.getItem("tw_token");
}

async function request(path, options = {}) {
  const token = getToken();
  const headers = { "Content-Type": "application/json", ...(options.headers || {}) };
  if (token) headers.Authorization = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${path}`, { ...options, headers });
  if (!res.ok) {
    const data = await res.json().catch(() => ({}));
    throw new Error(data.detail || "Request failed");
  }
  return res.status === 204 ? null : res.json();
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
  dashboardWeekly: () => request("/dashboard/weekly-activity"),
  contents: (params) => request(`/contents${buildQuery(params)}`),
  achievementsVitrine: () => request("/achievements/vitrine"),
};
