import { Navigate, Route, Routes, useLocation } from "react-router-dom";
import Navbar from "./components/Navbar";
import { useAuth } from "./context/AuthContext";
import Auth from "./pages/Auth";
import Bookmarks from "./pages/Bookmarks";
import Dashboard from "./pages/Dashboard";
import Explore from "./pages/Explore";
import Onboarding from "./pages/Onboarding";
import Progress from "./pages/Progress";

function Protected({ children }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  if (loading) return <div className="page">Loading...</div>;
  if (!user) return <Navigate to="/login" replace />;
  if (!user.onboarding_completed && location.pathname !== "/onboarding") return <Navigate to="/onboarding" replace />;
  return children;
}

const TOPBAR_TITLES = {
  "/": "Dashboard",
  "/explore": "Explore",
  "/bookmarks": "Bookmarks",
  "/progress": "Progress",
  "/onboarding": "Onboarding",
};

function AppTopBar() {
  const { pathname } = useLocation();
  const title = TOPBAR_TITLES[pathname] ?? "TimeWise";
  return (
    <header className="app-topbar">
      <div>
        <p className="app-topbar__sub">Precision · TimeWise</p>
        <h2 className="app-topbar__title">{title}</h2>
      </div>
    </header>
  );
}

function AuthenticatedRoutes() {
  return (
    <Routes>
      <Route
        path="/onboarding"
        element={
          <Protected>
            <Onboarding />
          </Protected>
        }
      />
      <Route
        path="/"
        element={
          <Protected>
            <Dashboard />
          </Protected>
        }
      />
      <Route
        path="/explore"
        element={
          <Protected>
            <Explore />
          </Protected>
        }
      />
      <Route
        path="/bookmarks"
        element={
          <Protected>
            <Bookmarks />
          </Protected>
        }
      />
      <Route
        path="/progress"
        element={
          <Protected>
            <Progress />
          </Protected>
        }
      />
      <Route path="/dashboard" element={<Navigate to="/" replace />} />
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

export default function App() {
  const { user, loading } = useAuth();

  if (loading) return <div className="page fade-up">Loading...</div>;

  if (!user) {
    return (
      <Routes>
        <Route path="/login" element={<Auth />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    );
  }

  return (
    <div className="app-shell">
      <Navbar />
      <main className="app-main">
        <AppTopBar />
        <div className="app-main__inner">
          <AuthenticatedRoutes />
        </div>
      </main>
    </div>
  );
}
