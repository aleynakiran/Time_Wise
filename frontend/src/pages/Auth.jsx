import { useState } from "react";
import { useNavigate } from "react-router-dom";
import ThemeToggle from "../components/ThemeToggle";
import { useAuth } from "../context/AuthContext";

export default function Auth() {
  const [mode, setMode] = useState("login");
  const [form, setForm] = useState({ email: "", password: "", username: "" });
  const [error, setError] = useState("");
  const { login } = useAuth();
  const navigate = useNavigate();

  const submit = async (e) => {
    e.preventDefault();
    try {
      const user = await login(form, mode);
      if (mode === "register" || !user.onboarding_completed) navigate("/onboarding");
      else navigate("/");
    } catch (err) {
      setError(err.message);
    }
  };

  return (
    <div className="page center fade-up">
      <div className="card auth-card">
        <div className="row">
          <button className={`btn ${mode === "login" ? "" : "ghost"}`} onClick={() => setMode("login")}>
            Login
          </button>
          <button className={`btn ${mode === "register" ? "" : "ghost"}`} onClick={() => setMode("register")}>
            Register
          </button>
        </div>
        <form onSubmit={submit} className="col">
          {mode === "register" && (
            <input
              placeholder="Username"
              value={form.username}
              onChange={(e) => setForm({ ...form, username: e.target.value })}
              required
            />
          )}
          <input
            type="email"
            placeholder="Email"
            value={form.email}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
            required
          />
          <input
            type="password"
            placeholder="Password"
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
            required
          />
          {error && <p className="error">{error}</p>}
          <button className="btn" type="submit">
            {mode === "login" ? "Login" : "Create Account"}
          </button>
          <div className="auth-theme-row">
            <ThemeToggle />
          </div>
        </form>
      </div>
    </div>
  );
}
