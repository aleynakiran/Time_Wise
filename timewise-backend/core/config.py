from functools import lru_cache
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    app_name: str = "TimeWise API"
    secret_key: str = "change-this-secret-in-env"
    algorithm: str = "HS256"
    access_token_expire_minutes: int = 60 * 24 * 7
    database_url: str = "postgresql+psycopg://postgres:postgres@localhost:5432/timewise"
    cors_origin: str = "http://localhost:5173"


@lru_cache
def get_settings() -> Settings:
    return Settings()
