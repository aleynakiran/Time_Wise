import enum
from datetime import date, datetime

from sqlalchemy import Boolean, Date, DateTime, Enum, Float, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from core.database import Base


class GoalEnum(str, enum.Enum):
    learn = "learn"
    focus = "focus"
    relax = "relax"
    productive = "productive"
    create = "create"


class DifficultyEnum(str, enum.Enum):
    beginner = "beginner"
    intermediate = "intermediate"
    advanced = "advanced"


class ContentTypeEnum(str, enum.Enum):
    article = "article"
    video = "video"
    podcast = "podcast"
    flashcard = "flashcard"
    exercise = "exercise"
    journaling = "journaling"
    tutorial = "tutorial"
    quiz = "quiz"
    book_summary = "book_summary"
    book = "book"
    game = "game"
    music_playlist = "music_playlist"
    documentary = "documentary"


class SessionStatusEnum(str, enum.Enum):
    active = "active"
    completed = "completed"
    abandoned = "abandoned"


class BadgeTierEnum(str, enum.Enum):
    bronze = "bronze"
    silver = "silver"
    gold = "gold"
    platinum = "platinum"


class User(Base):
    __tablename__ = "users"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    email: Mapped[str] = mapped_column(String(150), unique=True, nullable=False)
    username: Mapped[str] = mapped_column(String(50), unique=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    display_name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(String(255), nullable=True)
    onboarding_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    preferences = relationship("UserPreference", back_populates="user", uselist=False)
    topics = relationship("UserTopic", back_populates="user")
    stats = relationship("UserStat", back_populates="user", uselist=False)


class UserPreference(Base):
    __tablename__ = "user_preferences"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, nullable=False)
    default_goal: Mapped[GoalEnum] = mapped_column(Enum(GoalEnum, name="learning_goal"), nullable=False, default=GoalEnum.learn)
    default_difficulty: Mapped[DifficultyEnum] = mapped_column(
        Enum(DifficultyEnum, name="difficulty_level"), nullable=False, default=DifficultyEnum.beginner
    )
    prefers_offline: Mapped[bool] = mapped_column("prefer_offline", Boolean, default=False)
    preferred_language: Mapped[str] = mapped_column(String(10), default="en")
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)

    user = relationship("User", back_populates="preferences")


class Topic(Base):
    __tablename__ = "topics"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    slug: Mapped[str] = mapped_column(String(100), unique=True, nullable=False)
    name: Mapped[str] = mapped_column(String(80), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    icon_name: Mapped[str | None] = mapped_column(String(50), nullable=True)
    color_hex: Mapped[str | None] = mapped_column(String(7), nullable=True)

    subtags = relationship("TopicSubtag", back_populates="topic")


class TopicSubtag(Base):
    __tablename__ = "topic_subtags"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    topic_id: Mapped[int] = mapped_column(ForeignKey("topics.id"), nullable=False)
    name: Mapped[str] = mapped_column("label", String(80), nullable=False)
    slug: Mapped[str] = mapped_column(String(80), nullable=False)
    display_order: Mapped[int] = mapped_column(Integer, default=0)

    topic = relationship("Topic", back_populates="subtags")


class UserTopic(Base):
    __tablename__ = "user_topics"
    __table_args__ = (UniqueConstraint("user_id", "topic_id", name="uq_user_topics"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    topic_id: Mapped[int] = mapped_column(ForeignKey("topics.id"), nullable=False)
    weight: Mapped[int] = mapped_column(Integer, default=5)
    source: Mapped[str] = mapped_column(String(20), default="onboarding")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)

    user = relationship("User", back_populates="topics")
    topic = relationship("Topic")


class OnboardingQuestion(Base):
    __tablename__ = "onboarding_questions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    question_text: Mapped[str] = mapped_column(String(255), nullable=False)
    answer_type: Mapped[str] = mapped_column(String(20), default="multi_select")
    display_order: Mapped[int] = mapped_column(Integer, default=0)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)


class UserOnboardingAnswer(Base):
    __tablename__ = "user_onboarding_answers"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    question_id: Mapped[int] = mapped_column(ForeignKey("onboarding_questions.id"), nullable=False)
    answer_text: Mapped[str] = mapped_column("answer_value", Text, nullable=False)
    answered_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)


class Author(Base):
    __tablename__ = "authors"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    name: Mapped[str] = mapped_column(String(120), nullable=False)
    bio: Mapped[str | None] = mapped_column(Text, nullable=True)
    website: Mapped[str | None] = mapped_column(String(255), nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(String(255), nullable=True)


class Content(Base):
    __tablename__ = "contents"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    author_id: Mapped[int] = mapped_column(ForeignKey("authors.id"), nullable=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    content_type: Mapped[ContentTypeEnum] = mapped_column(Enum(ContentTypeEnum, name="content_type"), nullable=False)
    difficulty: Mapped[DifficultyEnum] = mapped_column(
        Enum(DifficultyEnum, name="difficulty_level"), nullable=False, default=DifficultyEnum.beginner
    )
    duration_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    thumbnail_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    avg_rating: Mapped[float | None] = mapped_column(Float, nullable=True)
    is_offline_available: Mapped[bool] = mapped_column(Boolean, default=False)
    language: Mapped[str] = mapped_column(String(10), default="en")
    view_count: Mapped[int] = mapped_column(Integer, default=0)
    embedded_html: Mapped[str | None] = mapped_column(Text, nullable=True)
    ebook_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    playlist_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    page_count: Mapped[int] = mapped_column(Integer, nullable=True)
    xp_reward: Mapped[int] = mapped_column(Integer, default=10)
    preview_video_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
    is_published: Mapped[bool] = mapped_column(Boolean, default=True)

    author = relationship("Author")
    topics = relationship("ContentTopic", back_populates="content")


class ContentTopic(Base):
    __tablename__ = "content_topics"
    __table_args__ = (UniqueConstraint("content_id", "topic_id", name="uq_content_topics"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    content_id: Mapped[int] = mapped_column(ForeignKey("contents.id"), nullable=False)
    topic_id: Mapped[int] = mapped_column(ForeignKey("topics.id"), nullable=False)

    content = relationship("Content", back_populates="topics")
    topic = relationship("Topic")


class TimeSession(Base):
    __tablename__ = "time_sessions"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    available_minutes: Mapped[int] = mapped_column(Integer, nullable=False)
    goal: Mapped[GoalEnum | None] = mapped_column("selected_goal", Enum(GoalEnum, name="learning_goal"), nullable=True)
    difficulty: Mapped[DifficultyEnum | None] = mapped_column(
        "selected_difficulty", Enum(DifficultyEnum, name="difficulty_level"), nullable=True
    )
    is_offline: Mapped[bool] = mapped_column(Boolean, default=False)
    selected_topic_id: Mapped[int] = mapped_column(ForeignKey("topics.id"), nullable=True)
    xp_earned: Mapped[int] = mapped_column(Integer, default=0)
    status: Mapped[SessionStatusEnum] = mapped_column(
        Enum(SessionStatusEnum, name="session_status"), default=SessionStatusEnum.active
    )
    created_at: Mapped[datetime] = mapped_column("started_at", DateTime(timezone=True), default=datetime.utcnow)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)


class Recommendation(Base):
    __tablename__ = "recommendations"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    session_id: Mapped[int] = mapped_column(ForeignKey("time_sessions.id"), nullable=False)
    content_id: Mapped[int] = mapped_column(ForeignKey("contents.id"), nullable=False)
    score: Mapped[float] = mapped_column(Float, nullable=False)
    rank: Mapped[int] = mapped_column(Integer, nullable=False)
    reason_template: Mapped[str | None] = mapped_column(String(50), nullable=True)
    reason_text: Mapped[str | None] = mapped_column(Text, nullable=True)
    was_opened: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)

    content = relationship("Content")


class Bookmark(Base):
    __tablename__ = "bookmarks"
    __table_args__ = (UniqueConstraint("user_id", "content_id", name="uq_bookmarks"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    content_id: Mapped[int] = mapped_column(ForeignKey("contents.id"), nullable=False)
    note: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column("saved_at", DateTime(timezone=True), default=datetime.utcnow)

    content = relationship("Content")


class Progress(Base):
    __tablename__ = "progress"
    __table_args__ = (UniqueConstraint("user_id", "content_id", name="uq_progress"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    content_id: Mapped[int] = mapped_column(ForeignKey("contents.id"), nullable=False)
    completion_percentage: Mapped[int] = mapped_column(Integer, default=0)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)
    updated_at: Mapped[datetime] = mapped_column("last_updated", DateTime(timezone=True), default=datetime.utcnow)

    content = relationship("Content")


class UserStat(Base):
    __tablename__ = "user_stats"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), unique=True, nullable=False)
    total_xp: Mapped[int] = mapped_column(Integer, default=0)
    current_level: Mapped[int] = mapped_column(Integer, default=1)
    current_streak_days: Mapped[int] = mapped_column(Integer, default=0)
    longest_streak_days: Mapped[int] = mapped_column(Integer, default=0)
    total_sessions: Mapped[int] = mapped_column(Integer, default=0)
    total_minutes_spent: Mapped[int] = mapped_column(Integer, default=0)
    total_contents_completed: Mapped[int] = mapped_column(Integer, default=0)
    last_active_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    favorite_topic_id: Mapped[int | None] = mapped_column(ForeignKey("topics.id"), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)

    user = relationship("User", back_populates="stats")


class Achievement(Base):
    __tablename__ = "achievements"

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    key: Mapped[str] = mapped_column("slug", String(80), unique=True, nullable=False)
    title: Mapped[str] = mapped_column(String(120), nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    icon_name: Mapped[str | None] = mapped_column(String(50), nullable=True)
    tier: Mapped[BadgeTierEnum] = mapped_column(Enum(BadgeTierEnum, name="badge_tier"), nullable=False)
    xp_reward: Mapped[int] = mapped_column("xp_bonus", Integer, default=0)
    trigger_type: Mapped[str] = mapped_column(String(50), nullable=False)
    trigger_value: Mapped[int] = mapped_column(Integer, nullable=False)


class UserAchievement(Base):
    __tablename__ = "user_achievements"
    __table_args__ = (UniqueConstraint("user_id", "achievement_id", name="uq_user_achievements"),)

    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    achievement_id: Mapped[int] = mapped_column(ForeignKey("achievements.id"), nullable=False)
    earned_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)

    achievement = relationship("Achievement")
