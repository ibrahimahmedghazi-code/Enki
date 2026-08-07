from pydantic import BaseModel
from typing import List, Literal

CourseCategory = Literal[
    "IT", "Language", "Engineering",
    "Math", "Medical", "Management", "Science", "Design"
]

class LectureSchema(BaseModel):
    title: str
    lecture_order: int
    duration_minutes: int
    is_it_video: bool = True

class ModuleSchema(BaseModel):
    number_of_module: int
    lectures: List[LectureSchema]

class CourseCreateSchema(BaseModel):
    title: str
    author: str
    description: str
    category: CourseCategory
    stage: str
    image_path: str = "assets/images/app_icon.png"
    rating: float = 0.0
    modules: List[ModuleSchema]
