from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Topic
from routers.auth import get_current_user
from schemas.schemas import TopicOut

router = APIRouter(tags=["topics"])


@router.get("/topics", response_model=list[TopicOut])
def list_topics(db: Session = Depends(get_db), _=Depends(get_current_user)):
    return db.query(Topic).options(joinedload(Topic.subtags)).all()
