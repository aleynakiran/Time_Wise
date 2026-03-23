from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict, EmailStr, Field

from models.models import ContentTypeEnum, DifficultyEnum, GoalEnum, SessionStatusEnum


class RegisterIn(BaseModel):
    email: EmailStr
    username: str = Field(min_length=3, max_length=80)
    password: str = Field(min_length=6, max_length=128)


class LoginIn(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    email: str
    username: str
    onboarding_completed: bool


class TokenOut(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class TopicSubtagOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str  # maps to DB column label via ORM attribute


class TopicOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    slug: str
    name: str
    description: Optional[str] = None
    subtags: list[TopicSubtagOut] = []


class OnboardingCompleteIn(BaseModel):
    topic_slugs: list[str] = Field(min_length=1)


class UserTopicIn(BaseModel):
    topic_id: int
    weight: int = Field(ge=1, le=10)


class UserTopicOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    topic_id: int
    weight: int
    topic: TopicOut


class AuthorOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    name: str
    bio: Optional[str] = None


class TopicMiniOut(BaseModel):
    """Brief topic for content lists (bookmarks, recommendations)."""

    model_config = ConfigDict(from_attributes=True)
    id: int
    slug: str
    name: str


class ContentTopicLinkOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    topic_id: int
    topic: TopicMiniOut


class ContentOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    title: str
    description: Optional[str] = None
    url: Optional[str] = None
    content_type: ContentTypeEnum
    difficulty: DifficultyEnum
    duration_minutes: int
    avg_rating: Optional[float] = None
    is_offline_available: bool
    embedded_html: Optional[str] = None
    ebook_url: Optional[str] = None
    playlist_url: Optional[str] = None
    page_count: Optional[int] = None
    xp_reward: int
    preview_video_url: Optional[str] = None
    author: Optional[AuthorOut] = None
    topics: list[ContentTopicLinkOut] = []


class SessionCreateIn(BaseModel):
    available_minutes: int = Field(ge=1, le=240)
    goal: Optional[GoalEnum] = None
    difficulty: Optional[DifficultyEnum] = None
    selected_topic_id: Optional[int] = None
    is_offline: bool = False


class SessionOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    available_minutes: int
    goal: Optional[GoalEnum] = None
    difficulty: Optional[DifficultyEnum] = None
    is_offline: bool
    selected_topic_id: Optional[int] = None
    xp_earned: int
    status: SessionStatusEnum
    created_at: datetime


class RecommendationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    score: float
    rank: int
    reason_template: Optional[str] = None
    reason_text: Optional[str] = None
    was_opened: bool
    content: ContentOut


class BookmarkOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    content: ContentOut
    created_at: datetime


class ProgressOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    completion_percentage: int
    is_completed: bool
    content: ContentOut
    updated_at: datetime


class ProgressUpdateIn(BaseModel):
    completion_percentage: int = Field(ge=0, le=100)


class DashboardOut(BaseModel):
    total_sessions: int
    total_planned_minutes: int
    completed_contents: int
    bookmarked_contents: int
    completion_rate_pct: float
    total_xp: int
    current_level: int
    current_streak_days: int


class DashboardStatsOut(BaseModel):
    total_xp: int
    current_level: int
    current_streak_days: int
    longest_streak_days: int
    total_sessions: int
    total_minutes_spent: int
    total_contents_completed: int
    favorite_topic: Optional[str] = None


class AchievementOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    key: str
    title: str
    description: Optional[str] = None
    tier: str
    xp_reward: int


class UserAchievementOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)
    id: int
    earned_at: datetime
    achievement: AchievementOut


class AchievementVitrineOut(BaseModel):
    """All achievements + earned flag for Progress vitrine."""

    model_config = ConfigDict(from_attributes=True)
    id: int
    key: str
    title: str
    description: Optional[str] = None
    tier: str
    xp_reward: int
    earned: bool
    earned_at: Optional[datetime] = None


class WeeklyMinutesOut(BaseModel):
    """One calendar day in the last 7-day window."""

    day: date
    label: str  # e.g. Mon, Tue
    minutes: int


class QueueItemOut(BaseModel):
    """Compact recommendation item for dashboard queue widgets."""

    model_config = ConfigDict(from_attributes=True)
    id: int
    score: float
    rank: int
    was_opened: bool
    content: ContentOut
