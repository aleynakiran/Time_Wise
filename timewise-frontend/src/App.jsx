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

export default function App() {
  return (
    <>
      <Navbar />
      <Routes>
        <Route path="/login" element={<Auth />} />
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
        <Route
          path="/dashboard"
          element={<Navigate to="/" replace />}
        />
      </Routes>
    </>
  );
}
