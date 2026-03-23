import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";

export default function Auth() {
  const [mode, setMode] = useState("login");
  const [remember, setRemember] = useState(false);
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
    <div className="auth-page auth-page--marketing fade-up">
      <div className="auth-page__glow" aria-hidden />
      <main className="auth-split">
        <section className="auth-split__brand">
          <div className="auth-split__brand-glow1" />
          <div className="auth-split__brand-glow2" />
          <div className="auth-split__brand-inner">
            <div className="auth-brand-logo">
              <span className="auth-brand-logo__mark" aria-hidden>
                <span className="material-symbols-outlined">schedule</span>
              </span>
              <span className="auth-brand-logo__text">TimeWise</span>
            </div>
            <h1 className="auth-split__headline">
              Precision tracking for the <strong>technical mind.</strong>
            </h1>
            <p className="auth-split__lead">
              Access your atelier of productivity. Designed for clarity, built for performance.
            </p>
            <div className="auth-data-glass">
              <div className="auth-data-glass__label">
                <span className="auth-data-glass__icon-wrap" aria-hidden>
                  <span className="material-symbols-outlined">insights</span>
                </span>
                <span>Real-time metrics</span>
              </div>
              <div className="auth-data-glass__grid">
                <div>
                  <div className="auth-data-glass__val">99.9%</div>
                  <div className="auth-data-glass__cap">Accuracy rate</div>
                </div>
                <div>
                  <div className="auth-data-glass__val">1.2s</div>
                  <div className="auth-data-glass__cap">Sync latency</div>
                </div>
              </div>
            </div>
          </div>
        </section>

        <section className="auth-split__form">
          <header className="auth-form-header">
            <h2>{mode === "login" ? "Welcome back" : "Create your account"}</h2>
            <p className="auth-form-header__sub">
              {mode === "login"
                ? "Enter your credentials to access your dashboard."
                : "Sign up to personalize your sessions and recommendations."}
            </p>
          </header>

          <div className="auth-tabs" role="tablist" aria-label="Login or register">
            <button
              type="button"
              role="tab"
              aria-selected={mode === "login"}
              className={`auth-tab${mode === "login" ? " auth-tab--active" : ""}`}
              onClick={() => {
                setMode("login");
                setError("");
              }}
            >
              Login
            </button>
            <button
              type="button"
              role="tab"
              aria-selected={mode === "register"}
              className={`auth-tab${mode === "register" ? " auth-tab--active" : ""}`}
              onClick={() => {
                setMode("register");
                setError("");
              }}
            >
              Register
            </button>
          </div>

          <form onSubmit={submit} className="auth-form">
            {mode === "register" && (
              <div className="auth-field">
                <label className="auth-field__label" htmlFor="auth-username">
                  Username
                </label>
                <div className="auth-input-wrap">
                  <span className="auth-input-wrap__icon material-symbols-outlined" aria-hidden>
                    person
                  </span>
                  <input
                    id="auth-username"
                    name="username"
                    autoComplete="username"
                    placeholder="Your display name"
                    value={form.username}
                    onChange={(e) => setForm({ ...form, username: e.target.value })}
                    required
                  />
                </div>
              </div>
            )}

            <div className="auth-field">
              <label className="auth-field__label" htmlFor="auth-email">
                Email address
              </label>
              <div className="auth-input-wrap">
                <span className="auth-input-wrap__icon material-symbols-outlined" aria-hidden>
                  mail
                </span>
                <input
                  id="auth-email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  placeholder="name@company.com"
                  value={form.email}
                  onChange={(e) => setForm({ ...form, email: e.target.value })}
                  required
                />
              </div>
            </div>

            <div className="auth-field">
              <div className="auth-field__label-row">
                <label className="auth-field__label" htmlFor="auth-password">
                  Password
                </label>
                {mode === "login" && (
                  <a className="auth-forgot" href="#" onClick={(e) => e.preventDefault()}>
                    Forgot password?
                  </a>
                )}
              </div>
              <div className="auth-input-wrap">
                <span className="auth-input-wrap__icon material-symbols-outlined" aria-hidden>
                  lock
                </span>
                <input
                  id="auth-password"
                  name="password"
                  type="password"
                  autoComplete={mode === "login" ? "current-password" : "new-password"}
                  placeholder="••••••••"
                  value={form.password}
                  onChange={(e) => setForm({ ...form, password: e.target.value })}
                  required
                />
              </div>
            </div>

            {mode === "login" && (
              <label className="auth-remember">
                <input
                  type="checkbox"
                  checked={remember}
                  onChange={(e) => setRemember(e.target.checked)}
                />
                <span>Keep me signed in</span>
              </label>
            )}

            {error && <p className="auth-error">{error}</p>}

            <button className="auth-submit" type="submit">
              <span>{mode === "login" ? "Authenticate" : "Create account"}</span>
              <span className="material-symbols-outlined auth-submit__arrow" aria-hidden>
                arrow_forward
              </span>
            </button>

          </form>
        </section>
      </main>
    </div>
  );
}
