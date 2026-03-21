import { Link, NavLink, useNavigate } from "react-router-dom";
import ThemeToggle from "./ThemeToggle";
import { useAuth } from "../context/AuthContext";

const NAV_ITEMS = [
  { to: "/", label: "Home", end: true },
  { to: "/explore", label: "Explore", end: false },
  { to: "/bookmarks", label: "Bookmarks", end: false },
  { to: "/progress", label: "Progress", end: false },
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
            ◷
          </span>
          <h1 className="logo">TimeWise</h1>
        </Link>

        <div className="nav-links" role="navigation" aria-label="Primary">
          {NAV_ITEMS.map(({ to, label, end }) => (
            <NavLink
              key={to}
              to={to}
              end={end}
              className={({ isActive }) =>
                `nav-link${isActive ? " nav-link--active" : ""}`
              }
            >
              {label}
            </NavLink>
          ))}
        </div>

        <div className="nav-actions">
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
          <ThemeToggle />
        </div>
      </nav>
    </header>
  );
}
