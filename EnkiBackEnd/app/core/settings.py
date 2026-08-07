import os
from pathlib import Path
from dotenv import load_dotenv

# Load repo-root `.env` regardless of current working directory
_ROOT = Path(__file__).resolve().parent.parent.parent
load_dotenv(_ROOT / ".env")

class Settings:
    """
    Application settings strictly for PostgreSQL.
    DATABASE_URL should follow the format:
    postgresql://user:password@host:port/dbname
    """

    # We make this a non-optional string. If it's missing, 
    # the app should fail immediately rather than silently using SQLite.
    database_url: str = (os.getenv("DATABASE_URL") or "").strip()

    def __init__(self):
        if not self.database_url:
            raise ValueError(
                "CRITICAL: DATABASE_URL is not set in the .env file. "
                "PostgreSQL is required for the Enki backend."
            )

settings = Settings()
