from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Content, Recommendation, SessionStatusEnum, TimeSession, User, UserStat
from routers.auth import get_current_user
from schemas.schemas import RecommendationOut, SessionCreateIn, SessionOut
from services.recommender import generate_recommendations

router = APIRouter(prefix="/sessions", tags=["sessions"])


@router.post("", response_model=SessionOut)
def create_session(
    payload: SessionCreateIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = TimeSession(user_id=current_user.id, **payload.model_dump())
    db.add(session)
    db.commit()
    db.refresh(session)
    generate_recommendations(db, session)
    return session


@router.get("", response_model=list[SessionOut])
def list_sessions(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(TimeSession)
        .filter(TimeSession.user_id == current_user.id)
        .order_by(TimeSession.created_at.desc())
        .all()
    )


@router.get("/{session_id}/recommendations", response_model=list[RecommendationOut])
def list_recommendations(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    owned = db.query(TimeSession).filter(TimeSession.id == session_id, TimeSession.user_id == current_user.id).first()
    if not owned:
        raise HTTPException(status_code=404, detail="Session not found")
    return (
        db.query(Recommendation)
        .options(joinedload(Recommendation.content).joinedload(Content.author))
        .filter(Recommendation.session_id == session_id)
        .order_by(Recommendation.rank.asc())
        .all()
    )


@router.patch("/{session_id}/complete", response_model=SessionOut)
def complete_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = db.query(TimeSession).filter(TimeSession.id == session_id, TimeSession.user_id == current_user.id).first()
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    session.status = SessionStatusEnum.completed
    xp = max(5, session.available_minutes // 2)
    session.xp_earned = xp

    stats = db.query(UserStat).filter(UserStat.user_id == current_user.id).first()
    if stats:
        stats.total_xp += xp
        stats.total_sessions += 1
        stats.total_minutes_spent += session.available_minutes
        stats.current_level = max(1, (stats.total_xp // 100) + 1)

    db.commit()
    db.refresh(session)
    return session
