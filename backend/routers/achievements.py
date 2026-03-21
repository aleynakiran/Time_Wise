from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Achievement, User, UserAchievement
from routers.auth import get_current_user
from schemas.schemas import AchievementVitrineOut

router = APIRouter(prefix="/achievements", tags=["achievements"])


@router.get("/vitrine", response_model=list[AchievementVitrineOut])
def achievements_vitrine(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """All achievements with earned / locked state."""
    all_rows = db.query(Achievement).order_by(Achievement.id.asc()).all()
    earned_list = (
        db.query(UserAchievement)
        .options(joinedload(UserAchievement.achievement))
        .filter(UserAchievement.user_id == current_user.id)
        .all()
    )
    earned_map = {ua.achievement_id: ua for ua in earned_list}
    out: list[AchievementVitrineOut] = []
    for a in all_rows:
        ua = earned_map.get(a.id)
        out.append(
            AchievementVitrineOut(
                id=a.id,
                key=a.key,
                title=a.title,
                description=a.description,
                tier=a.tier.value if hasattr(a.tier, "value") else str(a.tier),
                xp_reward=a.xp_reward,
                earned=ua is not None,
                earned_at=ua.earned_at if ua else None,
            )
        )
    return out
