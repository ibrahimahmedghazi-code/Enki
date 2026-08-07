from sqlalchemy import Column, String, Float, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.infrastructure.models import Base
import uuid

class Course(Base):
    __tablename__ = "courses"

    courseid = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String(255), nullable=False)
    imagepath = Column(String(500), default="assets/images/app_icon.png")
    description = Column(Text)
    author = Column(String(100))
    category = Column(String(50))
    rating = Column(Float, default=0.0)
    stage = Column(String(500))

    modules = relationship("Module", back_populates="course", cascade="all, delete")
    enrollments = relationship("UserActivate", back_populates="course", cascade="all, delete")
