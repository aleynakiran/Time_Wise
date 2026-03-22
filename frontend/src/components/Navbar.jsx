import { Link, NavLink, useNavigate } from "react-router-dom";
import ThemeToggle from "./ThemeToggle";
import { useAuth } from "../context/AuthContext";

const NAV_ITEMS = [
  { to: "/", label: "Dashboard", icon: "dashboard", end: true },
  { to: "/explore", label: "Explore", icon: "explore", end: false },
  { to: "/bookmarks", label: "Bookmarks", icon: "bookmark", end: false },
  { to: "/progress", label: "Progress", icon: "analytics", end: false },
];

export default function Navbar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  if (!user) return null;

  return (
    <header className="nav-shell">
      <nav className="nav nav-bar card" aria-label="Main">
        <Link to="/" className="logo-link">
          <span className="logo-mark" aria-hidden>
            <span className="material-symbols-outlined" style={{ fontSize: "1.15rem" }}>
              schedule
            </span>
          </span>
          <div>
            <h1 className="logo">TimeWise</h1>
            <p className="sidebar-brand-sub">Power user mode</p>
          </div>
        </Link>

        <div className="nav-links" role="navigation" aria-label="Primary">
          {NAV_ITEMS.map(({ to, label, icon, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              className={({ isActive }) => `nav-link${isActive ? " nav-link--active" : ""}`}
            >
              <span className="material-symbols-outlined" aria-hidden>
                {icon}
              </span>
              {label}
            </NavLink>
          ))}
        </div>

        <div className="nav-actions">
          <Link to="/" className="sidebar-cta">
            Start session
          </Link>
          <ThemeToggle />
          <button
            type="button"
            className="btn btn-nav-logout"
            onClick={() => {
              logout();
              navigate("/login");
            }}
          >
            Log out
          </button>
        </div>
      </nav>
    </header>
  );
}
