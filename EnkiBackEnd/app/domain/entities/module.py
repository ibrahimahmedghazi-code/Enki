from uuid import UUID, uuid4
from pydantic import BaseModel, Field
from .lecture import Lecture
from typing import List


class Module(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    number_of_module: int =Field(...,alias="numberOfModule" )
    course_id: UUID = Field(alias="CourseID")
    number_of_module: int = Field(...,alias="NumberOfModule")
    is_it_finish: bool = Field(...,alias="isItfinish")
    lectures: List[Lecture] = Field(default_factory=list, alias="Lectures")

    class Config:
        populate_by_name = True

