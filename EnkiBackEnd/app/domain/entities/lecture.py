from pydantic import BaseModel, Field
from uuid import UUID,uuid4

class Lecture(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    title: str = Field(...,alias="title")
    lecture_url: str = Field(..., alias="lectureUrl")
    duration_minutes: int = Field(..., alias="durationMinutes")
    is_it_video: bool = Field(default=True, alias="isItvideo")
    is_it_finish: bool = Field(default=False, alias="isItfinish")

    class Config:
        populate_by_name = True



