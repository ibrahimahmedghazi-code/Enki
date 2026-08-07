from sqlalchemy import Column, String, Integer, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.infrastructure.models import Base
import uuid

class User(Base):
    __tablename__ = "users"

    userid = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    fullname = Column(String(50), nullable=False)
    workat = Column(String(255))
    age = Column(Integer)
    userdescription = Column(Text)
    speciality = Column(String(100))
    profilepicturepath = Column(String(500), default="assets/images/app_icon.png")

    enrollments = relationship("UserActivate", back_populates="user", cascade="all, delete")
