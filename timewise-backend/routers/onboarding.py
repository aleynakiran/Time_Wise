from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Topic, User, UserTopic
from routers.auth import get_current_user
from schemas.schemas import OnboardingCompleteIn, UserTopicIn, UserTopicOut

router = APIRouter(tags=["onboarding", "user_topics"])


@router.post("/onboarding/complete")
def complete_onboarding(
    payload: OnboardingCompleteIn,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    topics = db.query(Topic).filter(Topic.slug.in_(payload.topic_slugs)).all()
    if not topics:
        raise HTTPException(status_code=400, detail="No valid topics selected")

    db.query(UserTopic).filter(UserTopic.user_id == current_user.id).delete()
    for topic in topics:
        # Keep onboarding defaults at mid-high weight so topic signal is meaningful.
        db.add(UserTopic(user_id=current_user.id, topic_id=topic.id, weight=7))

    current_user.onboarding_completed = True
    db.commit()
    return {"ok": True}


@router.get("/users/me/topics", response_model=list[UserTopicOut])
def user_topics(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(UserTopic)
        .options(joinedload(UserTopic.topic).joinedload(Topic.subtags))
        .filter(UserTopic.user_id == current_user.id)
        .all()
    )


@router.post("/users/me/topics", response_model=list[UserTopicOut])
def update_user_topics(
    payload: list[UserTopicIn],
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    db.query(UserTopic).filter(UserTopic.user_id == current_user.id).delete()
    for item in payload:
        db.add(UserTopic(user_id=current_user.id, topic_id=item.topic_id, weight=item.weight))
    db.commit()
    return (
        db.query(UserTopic)
        .options(joinedload(UserTopic.topic).joinedload(Topic.subtags))
        .filter(UserTopic.user_id == current_user.id)
        .all()
    )
