import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { api } from "../api";
import { useAuth } from "../context/AuthContext";

const TOPIC_ICONS = [
  "devices",
  "palette",
  "payments",
  "self_improvement",
  "campaign",
  "science",
  "school",
  "business_center",
  "eco",
  "monitoring",
  "brush",
  "sports_esports",
];

function iconForTopic(slug, index) {
  let h = index;
  for (let i = 0; i < slug.length; i += 1) h = (h + slug.charCodeAt(i)) % TOPIC_ICONS.length;
  return TOPIC_ICONS[h];
}

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
    <div className="onboarding-page fade-up">
      <div className="onboarding-bg" aria-hidden>
        <div className="onboarding-bg__blob onboarding-bg__blob--1" />
        <div className="onboarding-bg__blob onboarding-bg__blob--2" />
        <div className="onboarding-bg__blob onboarding-bg__blob--3" />
      </div>

      <div className="page">
        <div className="onboarding-stepper" aria-hidden>
          <span className="is-on" />
          <span className="is-on" />
          <span />
          <span />
        </div>

        <div className="onboarding-hero">
          <h1>
            Personalize your <span className="text-gradient">experience</span>
          </h1>
          <p>
            Choose categories that align with your daily focus. We&apos;ll tailor your dashboard to prioritize what
            matters most.
          </p>
        </div>

        <div className="onboarding-topics">
          {topics.map((topic, i) => {
            const isOn = selected.includes(topic.slug);
            return (
              <button
                key={topic.id}
                type="button"
                className={`onboarding-topic-card${isOn ? " is-selected" : ""}`}
                onClick={() => toggle(topic.slug)}
              >
                <span className="onboarding-topic-check material-symbols-outlined" style={{ fontVariationSettings: "'FILL' 1" }}>
                  check_circle
                </span>
                <span className="onboarding-topic-icon-wrap">
                  <span className={`material-symbols-outlined topic-icon`}>{iconForTopic(topic.slug, i)}</span>
                </span>
                <strong>{topic.name}</strong>
                <p>{topic.description}</p>
              </button>
            );
          })}
        </div>

        <div className="onboarding-features">
          <div className="onboarding-feature-card">
            <div className="onboarding-feature-icon onboarding-feature-icon--a">
              <span className="material-symbols-outlined">auto_awesome</span>
            </div>
            <div>
              <h3 style={{ margin: "0 0 0.35rem", fontSize: "1.15rem" }}>Smart discovery</h3>
              <p className="muted" style={{ margin: 0, fontSize: "0.92rem", lineHeight: 1.45 }}>
                Based on your selections, we surface sessions and content that match your goals.
              </p>
            </div>
          </div>
          <div className="onboarding-feature-card">
            <div className="onboarding-feature-icon onboarding-feature-icon--b">
              <span className="material-symbols-outlined">timer</span>
            </div>
            <div>
              <h3 style={{ margin: "0 0 0.35rem", fontSize: "1.15rem" }}>Custom focus tracks</h3>
              <p className="muted" style={{ margin: 0, fontSize: "0.92rem", lineHeight: 1.45 }}>
                Set time and mode on the dashboard — recommendations adapt to how you work.
              </p>
            </div>
          </div>
        </div>

        <div className="onboarding-cta-row">
          <button className="btn" disabled={selected.length === 0} onClick={submit} type="button">
            Continue setup
          </button>
          <div className="onboarding-privacy">
            <span className="material-symbols-outlined" style={{ fontSize: "1.1rem" }}>
              lock
            </span>
            Your preferences stay with your account.
          </div>
        </div>
      </div>
    </div>
  );
}
