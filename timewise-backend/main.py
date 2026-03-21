from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from core.config import get_settings
from core.database import Base, engine
from routers.achievements import router as achievements_router
from routers.auth import router as auth_router
from routers.bookmarks import router as bookmarks_router
from routers.content import router as content_router
from routers.dashboard import router as dashboard_router
from routers.onboarding import router as onboarding_router
from routers.progress import router as progress_router
from routers.sessions import router as sessions_router
from routers.topics import router as topics_router

settings = get_settings()
app = FastAPI(title=settings.app_name)

# Vite may use 5173, 5174, 5175… — allow any localhost port so "Load failed" / CORS does not break dev.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.cors_origin],
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

app.include_router(auth_router)
app.include_router(topics_router)
app.include_router(onboarding_router)
app.include_router(sessions_router)
app.include_router(bookmarks_router)
app.include_router(progress_router)
app.include_router(dashboard_router)
app.include_router(content_router)
app.include_router(achievements_router)


@app.get("/health")
def health():
    return {"ok": True}
