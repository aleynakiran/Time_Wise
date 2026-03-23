"""
Local dev helper: set a user's password when login fails but email is already registered.

Usage (from repo root or backend/):
  python -m scripts.reset_password you@email.com "YourNewPassword12"

Requires DATABASE_URL / backend .env to point at your Postgres.
"""
import sys

from sqlalchemy.orm import Session

from core.database import SessionLocal
from core.security import hash_password
from models.models import User


def main() -> None:
    if len(sys.argv) != 3:
        print("Usage: python -m scripts.reset_password <email> <new_password>")
        sys.exit(1)
    email = sys.argv[1].strip().lower()
    new_pw = sys.argv[2]
    if len(new_pw) < 6:
        print("Password must be at least 6 characters (matches API validation).")
        sys.exit(1)

    db: Session = SessionLocal()
    try:
        user = db.query(User).filter(User.email == email).first()
        if not user:
            print(f"No user with email: {email}")
            sys.exit(1)
        user.password_hash = hash_password(new_pw)
        db.commit()
        print(f"Password updated for {email}. You can log in now.")
    finally:
        db.close()


if __name__ == "__main__":
    main()
