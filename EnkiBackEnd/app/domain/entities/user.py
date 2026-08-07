from uuid import UUID, uuid4
from pydantic import BaseModel, Field, ConfigDict
from typing import Optional

class User(BaseModel):
    id: UUID = Field(default_factory=uuid4, alias="UserID")
    full_name: str = Field(..., alias="FullName")
    age: int = Field(..., alias="Age")
    speciality: str = Field(..., alias="Speciality")
    profile_picture_path: Optional[str] = Field(None, alias="ProfilePicturePath")
    description: Optional[str] = Field(None, alias="Description")
    work_at: Optional[str] = Field(None, alias="WorkAt")
    model_config = ConfigDict(populate_by_name=True)
