from uuid import UUID
from pydantic import BaseModel, Field, field_validator


class UserRegisterRequest(BaseModel):
    """User payload from Flutter; `id` is stored as primary key (UUID) in Enki `users`."""

    id: UUID
    full_name: str = Field(..., max_length=50)
    work_at: str | None = Field(None, max_length=255)
    age: int | None = Field(None, gt=0)
    user_description: str | None = None
    speciality: str | None = Field(None, max_length=100)
    profile_picture_path: str | None = Field(
        None, max_length=500, description="Defaults to app icon path if omitted"
    )

    @field_validator("age", mode="before")
    @classmethod
    def age_from_string(cls, v):
        if v is None or v == "":
            return None
        if isinstance(v, str):
            return int(v, 10)
        return v
