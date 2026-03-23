from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import func
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import (
    Bookmark,
    Content,
    ContentTopic,
    Progress,
    Recommendation,
    SessionStatusEnum,
    TimeSession,
    Topic,
    User,
    UserAchievement,
    UserStat,
    UserTopic,
)
from routers.auth import get_current_user
from schemas.schemas import DashboardOut, DashboardStatsOut, ProgressOut, QueueItemOut, UserAchievementOut, WeeklyMinutesOut

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get("", response_model=DashboardOut)
def dashboard(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    stats = db.query(UserStat).filter(UserStat.user_id == current_user.id).first()
    total_sessions = db.query(TimeSession).filter(TimeSession.user_id == current_user.id).count()
    total_planned = (
        db.query(func.coalesce(func.sum(TimeSession.available_minutes), 0))
        .filter(TimeSession.user_id == current_user.id)
        .scalar()
    )
    completed_contents = db.query(Progress).filter(Progress.user_id == current_user.id, Progress.is_completed.is_(True)).count()
    bookmarked = db.query(Bookmark).filter(Bookmark.user_id == current_user.id).count()
    total_prog = db.query(Progress).filter(Progress.user_id == current_user.id).count()
    completion_rate = round((completed_contents / total_prog) * 100, 2) if total_prog else 0.0

    return DashboardOut(
        total_sessions=total_sessions,
        total_planned_minutes=int(total_planned or 0),
        completed_contents=completed_contents,
        bookmarked_contents=bookmarked,
        completion_rate_pct=completion_rate,
        total_xp=stats.total_xp if stats else 0,
        current_level=stats.current_level if stats else 1,
        current_streak_days=stats.current_streak_days if stats else 0,
    )


@router.get("/stats", response_model=DashboardStatsOut)
def dashboard_stats(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    stats = db.query(UserStat).filter(UserStat.user_id == current_user.id).first()
    fav = (
        db.query(Topic.name)
        .join(UserTopic, UserTopic.topic_id == Topic.id)
        .filter(UserTopic.user_id == current_user.id)
        .order_by(UserTopic.weight.desc())
        .first()
    )
    return DashboardStatsOut(
        total_xp=stats.total_xp if stats else 0,
        current_level=stats.current_level if stats else 1,
        current_streak_days=stats.current_streak_days if stats else 0,
        longest_streak_days=stats.longest_streak_days if stats else 0,
        total_sessions=stats.total_sessions if stats else 0,
        total_minutes_spent=stats.total_minutes_spent if stats else 0,
        total_contents_completed=stats.total_contents_completed if stats else 0,
        favorite_topic=fav[0] if fav else None,
    )


@router.get("/achievements", response_model=list[UserAchievementOut])
def dashboard_achievements(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(UserAchievement)
        .options(joinedload(UserAchievement.achievement))
        .filter(UserAchievement.user_id == current_user.id)
        .all()
    )


@router.get("/continue", response_model=ProgressOut | None)
def continue_where_left(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Latest incomplete progress row for 'Continue' widget."""
    p = (
        db.query(Progress)
        .options(
            joinedload(Progress.content).joinedload(Content.author),
            joinedload(Progress.content).joinedload(Content.topics).joinedload(ContentTopic.topic),
        )
        .filter(Progress.user_id == current_user.id, Progress.is_completed.is_(False))
        .order_by(Progress.updated_at.desc())
        .first()
    )
    if p is not None and p.completion_percentage >= 100:
        return None
    return p


@router.get("/weekly-activity", response_model=list[WeeklyMinutesOut])
def weekly_activity(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """Last 7 calendar days: sum of planned minutes from completed sessions per day."""
    now = datetime.now(timezone.utc)
    end = now.date()
    start = end - timedelta(days=6)
    t0 = datetime.combine(start, datetime.min.time()).replace(tzinfo=timezone.utc)
    sessions = (
        db.query(TimeSession)
        .filter(
            TimeSession.user_id == current_user.id,
            TimeSession.status == SessionStatusEnum.completed,
            TimeSession.created_at >= t0,
        )
        .all()
    )
    by_day: dict = {}
    for s in sessions:
        ca = s.created_at
        if ca.tzinfo is None:
            ca = ca.replace(tzinfo=timezone.utc)
        d = ca.date()
        by_day[d] = by_day.get(d, 0) + int(s.available_minutes)

    labels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    out: list[WeeklyMinutesOut] = []
    for i in range(7):
        d = start + timedelta(days=i)
        wd = d.weekday()
        out.append(WeeklyMinutesOut(day=d, label=labels[wd], minutes=by_day.get(d, 0)))
    return out


@router.get("/queue", response_model=list[QueueItemOut])
def dashboard_queue(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Top unopened recommendations from the user's latest session."""
    latest_session = (
        db.query(TimeSession)
        .filter(TimeSession.user_id == current_user.id)
        .order_by(TimeSession.created_at.desc())
        .first()
    )
    if not latest_session:
        return []

    return (
        db.query(Recommendation)
        .options(
            joinedload(Recommendation.content).joinedload(Content.author),
            joinedload(Recommendation.content).joinedload(Content.topics).joinedload(ContentTopic.topic),
        )
        .filter(
            Recommendation.session_id == latest_session.id,
            Recommendation.was_opened.is_(False),
        )
        .order_by(Recommendation.rank.asc(), Recommendation.id.asc())
        .limit(5)
        .all()
    )
