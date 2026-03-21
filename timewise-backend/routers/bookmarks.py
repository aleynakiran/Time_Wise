from fastapi import APIRouter, Depends
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, joinedload

from core.database import get_db
from models.models import Bookmark, Content, ContentTopic, User
from routers.auth import get_current_user
from schemas.schemas import BookmarkOut

router = APIRouter(prefix="/bookmarks", tags=["bookmarks"])


@router.get("", response_model=list[BookmarkOut])
def list_bookmarks(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return (
        db.query(Bookmark)
        .options(
            joinedload(Bookmark.content).joinedload(Content.author),
            joinedload(Bookmark.content).joinedload(Content.topics).joinedload(ContentTopic.topic),
        )
        .filter(Bookmark.user_id == current_user.id)
        .order_by(Bookmark.created_at.desc())
        .all()
    )


@router.post("/{content_id}")
def add_bookmark(content_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    bm = Bookmark(user_id=current_user.id, content_id=content_id)
    db.add(bm)
    try:
        db.commit()
    except IntegrityError:
        db.rollback()
    return {"ok": True}


@router.delete("/{content_id}")
def remove_bookmark(content_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    db.query(Bookmark).filter(Bookmark.user_id == current_user.id, Bookmark.content_id == content_id).delete()
    db.commit()
    return {"ok": True}
