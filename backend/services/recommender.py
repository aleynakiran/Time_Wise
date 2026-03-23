import hashlib
from sqlalchemy import and_, or_
from sqlalchemy.orm import Session, joinedload

from models.models import (
    Content,
    ContentTypeEnum,
    ContentTopic,
    Recommendation,
    TimeSession,
    Topic,
    UserTopic,
)

# Topic slugs (see `topics.slug`) — how well each mode fits *videos & documentaries*.
# Used so Learn vs Relax do not surface the same generic "video" rows.
TOPIC_SLUG_LEARN_VIDEO: dict[str, float] = {
    "tech": 1.0,
    "languages": 0.88,
    "productivity": 0.95,
    "health": 0.62,
    "arts": 0.58,
    "music": 0.52,
    "culture": 0.92,
    "philosophy": 0.78,
    "psychology": 0.82,
    "finance": 0.9,
    "meditation": 0.22,
    "entrepreneurship": 0.95,
}

TOPIC_SLUG_RELAX_VIDEO: dict[str, float] = {
    "tech": 0.12,
    "languages": 0.42,
    "productivity": 0.18,
    "health": 0.78,
    "arts": 0.96,
    "music": 1.0,
    "culture": 0.58,
    "philosophy": 0.72,
    "psychology": 0.88,
    "finance": 0.22,
    "meditation": 1.0,
    "entrepreneurship": 0.18,
}

# Title/description hints when topics are missing or ambiguous.
_LEARN_HINTS = (
    "tutorial",
    "course",
    "learn ",
    "explained",
    "masterclass",
    "lecture",
    "introduction to",
    "how to",
    "guide",
    "crash course",
    "full overview",
)
_RELAX_HINTS = (
    "meditation",
    "mindfulness",
    "calm",
    "sleep",
    "ambient",
    "asmr",
    "yoga",
    "stretch",
    "relax",
    "nature sounds",
    "lo-fi",
    "playlist",
)


def _text_blob(content: Content) -> str:
    parts = [content.title or "", content.description or ""]
    return " ".join(parts).lower()


def _keyword_affinity_bonus(goal_val: str, text: str) -> float:
    """Small 0–0.12 boost when copy clearly matches the mode."""
    if goal_val == "learn":
        n = sum(1 for h in _LEARN_HINTS if h in text)
    elif goal_val == "relax":
        n = sum(1 for h in _RELAX_HINTS if h in text)
    else:
        return 0.0
    return round(min(0.12, n * 0.04), 3)


def _topic_slugs(content: Content) -> set[str]:
    out: set[str] = set()
    for ct in content.topics:
        slug = getattr(getattr(ct, "topic", None), "slug", None)
        if slug:
            out.add(slug)
    return out


def _max_affinity(slugs: set[str], table: dict[str, float]) -> float:
    if not slugs:
        return 0.5
    return max(table.get(s, 0.5) for s in slugs)


def _video_doc_mode_multiplier(content: Content, goal_val: str | None) -> float | None:
    """
    Learn/Relax: filter & weight videos + documentaries by topic + title hints.
    Returns None = skip. Returns 1.0 when this rule does not apply (other types / goals).
    """
    if goal_val not in ("learn", "relax"):
        return 1.0
    if content.content_type not in (ContentTypeEnum.video, ContentTypeEnum.documentary):
        return 1.0

    slugs = _topic_slugs(content)
    text = _text_blob(content)
    learn_a = min(1.0, _max_affinity(slugs, TOPIC_SLUG_LEARN_VIDEO) + _keyword_affinity_bonus("learn", text))
    relax_a = min(1.0, _max_affinity(slugs, TOPIC_SLUG_RELAX_VIDEO) + _keyword_affinity_bonus("relax", text))

    if goal_val == "learn" and learn_a < 0.32:
        return None
    if goal_val == "relax" and relax_a < 0.32:
        return None
    if goal_val == "relax" and (learn_a - relax_a) > 0.45:
        return None
    if goal_val == "learn" and (relax_a - learn_a) > 0.45:
        return None

    aff = learn_a if goal_val == "learn" else relax_a
    return round(0.58 + 0.42 * aff, 4)


# Each mode only draws from these types so Learn / Focus / Relax / Productivity stay visually different.
GOAL_CONTENT_MAP = {
    "learn": {
        ContentTypeEnum.article,
        ContentTypeEnum.video,
        ContentTypeEnum.book_summary,
        ContentTypeEnum.tutorial,
        ContentTypeEnum.quiz,
        ContentTypeEnum.documentary,
    },
    "focus": {ContentTypeEnum.flashcard, ContentTypeEnum.exercise, ContentTypeEnum.tutorial},
    "relax": {
        ContentTypeEnum.podcast,
        ContentTypeEnum.music_playlist,
        ContentTypeEnum.video,
        ContentTypeEnum.documentary,
        ContentTypeEnum.journaling,
        ContentTypeEnum.exercise,
    },
    "productive": {ContentTypeEnum.article, ContentTypeEnum.podcast, ContentTypeEnum.tutorial, ContentTypeEnum.quiz},
    "create": {ContentTypeEnum.game, ContentTypeEnum.journaling, ContentTypeEnum.video, ContentTypeEnum.tutorial},
}


def _duration_points(content_minutes: int, available: int) -> float:
    if content_minutes > available:
        return 0.0
    closeness = 1 - ((available - content_minutes) / max(available, 1))
    return max(0.0, round(40 * closeness, 2))


def _topic_points(
    content_topic_ids: set[int], weighted_user_topics: dict[int, int], selected_topic_id: int | None
) -> float:
    if selected_topic_id is not None:
        return 25.0 if selected_topic_id in content_topic_ids else 0.0

    if not content_topic_ids or not weighted_user_topics:
        return 0.0
    best = 0.0
    for tid in content_topic_ids:
        best = max(best, weighted_user_topics.get(tid, 0.0))
    normalized = min(best / 10.0, 1.0)
    return round(25 * normalized, 2)


def _goal_points(content_type: ContentTypeEnum, goal: str | None) -> float:
    if not goal:
        return 0.0
    return 35.0 if content_type in GOAL_CONTENT_MAP.get(goal, set()) else 0.0


def _difficulty_points(content_difficulty: str | None, target_difficulty: str | None) -> float:
    if not target_difficulty or not content_difficulty:
        return 0.0
    return 10.0 if content_difficulty == target_difficulty else 0.0


def _offline_points(session_offline: bool, content_offline: bool) -> float:
    if not session_offline:
        return 5.0
    return 5.0 if content_offline else 0.0


def _rating_points(avg_rating: float | None) -> float:
    normalized = min(max(avg_rating or 0.0, 0.0), 5.0) / 5.0
    return round(5 * normalized, 2)


def _score_for_db(raw: float) -> float:
    """DB constraint `recommendations_score_check`: score between 0 and 100 inclusive."""
    return max(0.0, min(100.0, round(float(raw), 2)))


def _reason_template(score_breakdown: dict[str, float]) -> str:
    order = [
        ("topic", "matches_topic"),
        ("goal", "matches_goal"),
        ("duration", "fits_duration"),
        ("rating", "top_rated"),
        ("offline", "offline_available"),
    ]
    key = max(order, key=lambda x: score_breakdown[x[0]])[1]
    return key


def _reason_text(template: str, minutes: int, topic_name: str | None) -> str:
    if template == "matches_topic" and topic_name:
        return f"Matches your \"{topic_name}\" interest and available {minutes} minutes."
    if template == "matches_goal":
        return f"Aligned with your goal and fits your {minutes}-minute window."
    if template == "fits_duration":
        return f"Fits your {minutes}-minute window very closely."
    if template == "top_rated":
        return "Top rated by users with similar preferences."
    return "Available offline and suitable for your current session."


def _has_playable_link():
    return or_(
        and_(Content.url.isnot(None), Content.url != ""),
        and_(Content.preview_video_url.isnot(None), Content.preview_video_url != ""),
        and_(Content.ebook_url.isnot(None), Content.ebook_url != ""),
        and_(Content.playlist_url.isnot(None), Content.playlist_url != ""),
        and_(Content.embedded_html.isnot(None), Content.embedded_html != ""),
    )


def _mode_jitter(session_id: int, goal: str | None, content_id: int) -> float:
    """Deterministic per (session, goal, item) so each mode orders candidates differently."""
    raw = hashlib.md5(f"{session_id}:{goal or 'none'}:{content_id}".encode()).hexdigest()
    return int(raw[:8], 16) / 0xFFFFFFFF


def _mode_secondary(content: Content, goal: str | None) -> float:
    """Tie-break / diversify: each mode prefers a slightly different signal."""
    if not goal:
        return 0.0
    rating = float(content.avg_rating or 0.0)
    dur = float(content.duration_minutes or 0)
    views = float(content.view_count or 0)
    if goal == "relax":
        return dur * 0.4 + rating * 2.0
    if goal == "focus":
        return -dur * 0.3 + rating * 3.0
    if goal == "learn":
        return rating * 4.0 + views * 0.01
    if goal == "productive":
        return views * 0.02 + rating * 3.0
    return rating


def _score_one(
    session: TimeSession,
    content: Content,
    weighted_user_topics: dict[int, int],
    selected_topic_name: str | None,
) -> tuple[float, str, str] | None:
    content_topic_ids = {ct.topic_id for ct in content.topics}
    if session.selected_topic_id is not None and session.selected_topic_id not in content_topic_ids:
        return None

    goal_val = session.goal.value if session.goal else None
    if goal_val and content.content_type not in GOAL_CONTENT_MAP.get(goal_val, set()):
        return None

    content_difficulty_val = None
    if content.difficulty is not None:
        try:
            content_difficulty_val = content.difficulty.value
        except (AttributeError, ValueError):
            content_difficulty_val = None

    score_parts = {
        "duration": _duration_points(content.duration_minutes, session.available_minutes),
        "topic": _topic_points(content_topic_ids, weighted_user_topics, session.selected_topic_id),
        "goal": _goal_points(content.content_type, goal_val),
        "difficulty": _difficulty_points(
            content_difficulty_val,
            session.difficulty.value if session.difficulty else None,
        ),
        "offline": _offline_points(session.is_offline, content.is_offline_available),
        "rating": _rating_points(content.avg_rating),
    }
    total = round(sum(score_parts.values()), 2)
    if total <= 0:
        return None
    vm = _video_doc_mode_multiplier(content, goal_val)
    if vm is None:
        return None
    total = round(total * vm, 2)
    if total <= 0:
        return None
    template = _reason_template(score_parts)
    reason = _reason_text(template, session.available_minutes, selected_topic_name)
    return total, template, reason


def generate_recommendations(db: Session, session: TimeSession) -> list[Recommendation]:
    user_topics = db.query(UserTopic).filter(UserTopic.user_id == session.user_id).all()
    weighted_user_topics = {ut.topic_id: ut.weight for ut in user_topics}

    query = (
        db.query(Content)
        .options(joinedload(Content.author), joinedload(Content.topics).joinedload(ContentTopic.topic))
        .filter(Content.is_published.is_(True))
        .filter(_has_playable_link())
    )
    if session.is_offline:
        query = query.filter(Content.is_offline_available.is_(True))
    candidates = query.all()

    selected_topic_name = None
    if session.selected_topic_id:
        topic = db.query(Topic).filter(Topic.id == session.selected_topic_id).first()
        selected_topic_name = topic.name if topic else None

    goal_val = session.goal.value if session.goal else None

    scored: list[tuple[Content, float, str, str, float]] = []
    for content in candidates:
        out = _score_one(session, content, weighted_user_topics, selected_topic_name)
        if not out:
            continue
        total, template, reason = out
        jitter = _mode_jitter(session.id, goal_val, content.id)
        secondary = _mode_secondary(content, goal_val)
        rank_score = total + jitter * 4.0 + secondary * 0.15
        scored.append((content, total, template, reason, rank_score))

    scored.sort(key=lambda row: row[4], reverse=True)
    top = [(c, t, tpl, r) for c, t, tpl, r, _ in scored[:6]]

    if not top:
        fallback_rows: list[tuple[Content, float, str, str, float]] = []
        for content in candidates:
            content_topic_ids = {ct.topic_id for ct in content.topics}
            if session.selected_topic_id is not None and session.selected_topic_id not in content_topic_ids:
                continue
            if content.duration_minutes > session.available_minutes:
                continue
            goal_val = session.goal.value if session.goal else None
            if goal_val and content.content_type not in GOAL_CONTENT_MAP.get(goal_val, set()):
                continue
            vm = _video_doc_mode_multiplier(content, goal_val)
            if vm is None:
                continue
            dur = _duration_points(content.duration_minutes, session.available_minutes)
            rating = _rating_points(content.avg_rating)
            total_fb = max(1.0, round(dur + rating, 2)) * vm
            jitter = _mode_jitter(session.id, goal_val, content.id)
            secondary = _mode_secondary(content, goal_val)
            rank_score = total_fb + jitter * 4.0 + secondary * 0.15
            fallback_rows.append(
                (
                    content,
                    total_fb,
                    "fits_duration",
                    f"Fits your {session.available_minutes}-minute window.",
                    rank_score,
                )
            )
        fallback_rows.sort(key=lambda r: r[4], reverse=True)
        top = [(c, t, tpl, r) for c, t, tpl, r, _ in fallback_rows[:6]]

    created = []
    for idx, (content, score, template, reason) in enumerate(top, start=1):
        rec = Recommendation(
            session_id=session.id,
            content_id=content.id,
            score=_score_for_db(score),
            rank=idx,
            reason_template=template,
            reason_text=reason,
        )
        db.add(rec)
        created.append(rec)

    db.commit()
    for rec in created:
        db.refresh(rec)
    return created
