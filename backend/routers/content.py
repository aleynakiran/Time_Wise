from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Content, ContentTopic, ContentTypeEnum, User
from routers.auth import get_current_user
from schemas.schemas import ContentOut

router = APIRouter(prefix="/contents", tags=["contents"])


@router.get("", response_model=list[ContentOut])
def list_contents(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    content_type: str | None = None,
    max_duration: int | None = None,
    limit: int = Query(24, ge=1, le=100),
    sort: str = Query("popular"),
):
    if sort not in ("popular", "recent"):
        raise HTTPException(status_code=400, detail="Invalid sort")
    """Published contents for catalog (Home)."""
    q = (
        db.query(Content)
        .options(
            joinedload(Content.author),
            joinedload(Content.topics).joinedload(ContentTopic.topic),
        )
        .filter(Content.is_published.is_(True))
    )
    if content_type:
        try:
            ct = ContentTypeEnum(content_type)
        except ValueError as e:
            raise HTTPException(status_code=400, detail="Invalid content_type") from e
        q = q.filter(Content.content_type == ct)
    if max_duration is not None:
        q = q.filter(Content.duration_minutes <= max_duration)
    if sort == "popular":
        q = q.order_by(Content.view_count.desc().nullslast(), Content.id.desc())
    else:
        q = q.order_by(Content.created_at.desc())
    return q.limit(limit).all()
