import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../api";
import { useAuth } from "../context/AuthContext";

export default function Onboarding() {
  const [topics, setTopics] = useState([]);
  const [selected, setSelected] = useState([]);
  const { user, setUser } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    api.topics().then(setTopics).catch(console.error);
  }, []);

  const toggle = (slug) => {
    setSelected((prev) => (prev.includes(slug) ? prev.filter((s) => s !== slug) : [...prev, slug]));
  };

  const submit = async () => {
    await api.completeOnboarding(selected);
    setUser({ ...user, onboarding_completed: true });
    navigate("/");
  };

  return (
    <div className="page fade-up">
      <h2>Choose your interests</h2>
      <div className="grid">
        {topics.map((topic) => (
          <button
            key={topic.id}
            className={`card topic-btn ${selected.includes(topic.slug) ? "selected" : ""}`}
            onClick={() => toggle(topic.slug)}
          >
            <strong>{topic.name}</strong>
            <p>{topic.description}</p>
          </button>
        ))}
      </div>
      <button className="btn" disabled={selected.length === 0} onClick={submit}>
        Continue
      </button>
    </div>
  );
}
