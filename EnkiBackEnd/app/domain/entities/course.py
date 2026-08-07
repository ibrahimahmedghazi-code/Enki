from uuid import UUID, uuid4
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional
from .module import Module

class Course(BaseModel):
    id: UUID = Field(default_factory=uuid4, alias="CourseID")
    title: str = Field(..., alias="Title")
    image_path: str = Field(..., alias="ImagePath")
    author: str = Field(..., alias="Author")
    description: Optional[str] = Field(None, alias="Description")
    category: str = Field(..., alias="Category")
    rating: float = Field(default=0.0, alias="Rating")
    stage: str = Field(..., validation_alias="Stage", serialization_alias="level")
    modules: Optional[List[Module]] = Field(default=None, alias="Modules")
    model_config = ConfigDict(populate_by_name=True)
