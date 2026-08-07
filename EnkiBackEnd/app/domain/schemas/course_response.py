from pydantic import BaseModel
from typing import List
from uuid import UUID

class LectureResponse(BaseModel):
    lectureid: UUID
    title: str
    lectureorder: int
    durationminutes: int
    isitvideo: bool
    lectureurl: str | None = None

    class Config:
        from_attributes = True

class ModuleResponse(BaseModel):
    moduleid: UUID
    numberofmodule: int
    lectures: List[LectureResponse]

    class Config:
        from_attributes = True

class CourseResponse(BaseModel):
    courseid: UUID
    title: str
    author: str
    description: str | None
    category: str
    stage: str | None
    imagepath: str
    rating: float
    modules: List[ModuleResponse]

    class Config:
        from_attributes = True
