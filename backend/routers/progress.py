from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Content, ContentTopic, Progress, User, UserStat
from routers.auth import get_current_user
from schemas.schemas import ProgressOut, ProgressUpdateIn, ProgressUpdateOut

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("", response_model=list[ProgressOut])
def list_progress(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(Progress)
        .options(joinedload(Progress.content).joinedload(Content.author))
        .filter(Progress.user_id == current_user.id)
        .order_by(Progress.updated_at.desc())
        .all()
    )


@router.put("/{content_id}", response_model=ProgressUpdateOut)
def upsert_progress(
    content_id: int,
    payload: ProgressUpdateIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    content_row = db.query(Content).filter(Content.id == content_id).first()
    if not content_row:
        raise HTTPException(status_code=404, detail="Content not found")

    progress = (
        db.query(Progress)
        .options(joinedload(Progress.content).joinedload(Content.author))
        .filter(Progress.user_id == current_user.id, Progress.content_id == content_id)
        .first()
    )
    if not progress:
        progress = Progress(user_id=current_user.id, content_id=content_id)
        db.add(progress)

    was_completed = bool(progress.is_completed)
    next_pct = int(payload.completion_percentage)

    progress.completion_percentage = next_pct
    progress.is_completed = next_pct == 100
    progress.updated_at = datetime.utcnow()

    newly_completed = progress.is_completed and not was_completed

    duration = int(content_row.duration_minutes or 0)
    xp_reward = int(content_row.xp_reward or 0)

    gained_minutes = duration if newly_completed else 0
    gained_xp = xp_reward if newly_completed else 0

    stats = db.query(UserStat).filter(UserStat.user_id == current_user.id).first()
    if not stats:
        stats = UserStat(user_id=current_user.id)
        db.add(stats)

    if newly_completed:
        stats.total_minutes_spent += gained_minutes
        stats.total_xp += gained_xp
        stats.total_contents_completed += 1
        stats.current_level = max(1, (stats.total_xp // 100) + 1)

    db.commit()
    fresh = (
        db.query(Progress)
        .options(
            joinedload(Progress.content).joinedload(Content.author),
            joinedload(Progress.content).joinedload(Content.topics).joinedload(ContentTopic.topic),
        )
        .filter(Progress.user_id == current_user.id, Progress.content_id == content_id)
        .first()
    )
    if not fresh:
        raise HTTPException(status_code=404, detail="Progress not found")

    base = ProgressOut.model_validate(fresh)
    return ProgressUpdateOut(
        **base.model_dump(),
        gained_xp=gained_xp,
        gained_minutes=gained_minutes,
        newly_completed=newly_completed,
    )
