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

GOAL_CONTENT_MAP = {
    "learn": {ContentTypeEnum.article, ContentTypeEnum.video, ContentTypeEnum.book_summary, ContentTypeEnum.tutorial, ContentTypeEnum.quiz},
    "focus": {ContentTypeEnum.flashcard, ContentTypeEnum.exercise, ContentTypeEnum.tutorial},
    # Watch / listen friendly: video + podcast + playlists + calm content
    "relax": {
        ContentTypeEnum.video,
        ContentTypeEnum.podcast,
        ContentTypeEnum.music_playlist,
        ContentTypeEnum.documentary,
        ContentTypeEnum.exercise,
        ContentTypeEnum.journaling,
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
    # Explicit topic override should strongly steer results toward that topic.
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
    return 15.0 if content_type in GOAL_CONTENT_MAP.get(goal, set()) else 0.0


def _difficulty_points(content_difficulty: str, target_difficulty: str | None) -> float:
    if not target_difficulty:
        return 0.0
    return 10.0 if content_difficulty == target_difficulty else 0.0


def _offline_points(session_offline: bool, content_offline: bool) -> float:
    if not session_offline:
        return 5.0
    return 5.0 if content_offline else 0.0


def _rating_points(avg_rating: float | None) -> float:
    normalized = min(max(avg_rating or 0.0, 0.0), 5.0) / 5.0
    return round(5 * normalized, 2)


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


def generate_recommendations(db: Session, session: TimeSession) -> list[Recommendation]:
    user_topics = db.query(UserTopic).filter(UserTopic.user_id == session.user_id).all()
    weighted_user_topics = {ut.topic_id: ut.weight for ut in user_topics}

    query = db.query(Content).options(joinedload(Content.author), joinedload(Content.topics).joinedload(ContentTopic.topic))
    if session.is_offline:
        query = query.filter(Content.is_offline_available.is_(True))
    candidates = query.all()

    selected_topic_name = None
    if session.selected_topic_id:
        topic = db.query(Topic).filter(Topic.id == session.selected_topic_id).first()
        selected_topic_name = topic.name if topic else None

    scored = []
    for content in candidates:
        content_topic_ids = {ct.topic_id for ct in content.topics}
        # If user picked a topic override, skip contents outside that topic.
        if session.selected_topic_id is not None and session.selected_topic_id not in content_topic_ids:
            continue

        score_parts = {
            "duration": _duration_points(content.duration_minutes, session.available_minutes),
            "topic": _topic_points(content_topic_ids, weighted_user_topics, session.selected_topic_id),
            "goal": _goal_points(content.content_type, session.goal.value if session.goal else None),
            "difficulty": _difficulty_points(content.difficulty.value, session.difficulty.value if session.difficulty else None),
            "offline": _offline_points(session.is_offline, content.is_offline_available),
            "rating": _rating_points(content.avg_rating),
        }
        total = round(sum(score_parts.values()), 2)
        if total <= 0:
            continue
        template = _reason_template(score_parts)
        reason = _reason_text(template, session.available_minutes, selected_topic_name)
        scored.append((content, total, template, reason))

    scored.sort(key=lambda row: row[1], reverse=True)
    top = scored[:6]

    # Fallback: strict filters can yield zero rows — still show picks that fit duration (+ topic if set)
    if not top:
        fallback_rows = []
        for content in candidates:
            ct_ids = {ct.topic_id for ct in content.topics}
            if session.selected_topic_id is not None and session.selected_topic_id not in ct_ids:
                continue
            if content.duration_minutes > session.available_minutes:
                continue
            dur = _duration_points(content.duration_minutes, session.available_minutes)
            rating = _rating_points(content.avg_rating)
            total_fb = max(1.0, round(dur + rating, 2))
            fallback_rows.append(
                (
                    content,
                    total_fb,
                    "fits_duration",
                    f"Fits your {session.available_minutes}-minute window.",
                )
            )
        fallback_rows.sort(key=lambda r: r[1], reverse=True)
        top = fallback_rows[:6]

    created = []
    for idx, (content, score, template, reason) in enumerate(top, start=1):
        rec = Recommendation(
            session_id=session.id,
            content_id=content.id,
            score=score,
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
