from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Content, Progress, User, UserStat
from routers.auth import get_current_user
from schemas.schemas import ProgressOut, ProgressUpdateIn

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


@router.put("/{content_id}", response_model=ProgressOut)
def upsert_progress(
    content_id: int,
    payload: ProgressUpdateIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    progress = (
        db.query(Progress)
        .options(joinedload(Progress.content).joinedload(Content.author))
        .filter(Progress.user_id == current_user.id, Progress.content_id == content_id)
        .first()
    )
    if not progress:
        progress = Progress(user_id=current_user.id, content_id=content_id)
        db.add(progress)

    progress.completion_percentage = payload.completion_percentage
    progress.is_completed = payload.completion_percentage == 100
    progress.updated_at = datetime.utcnow()

    if progress.is_completed:
        stats = db.query(UserStat).filter(UserStat.user_id == current_user.id).first()
        if stats:
            stats.total_contents_completed += 1

    db.commit()
    fresh = (
        db.query(Progress)
        .options(joinedload(Progress.content).joinedload(Content.author))
        .filter(Progress.user_id == current_user.id, Progress.content_id == content_id)
        .first()
    )
    if not fresh:
        raise HTTPException(status_code=404, detail="Progress not found")
    return fresh
