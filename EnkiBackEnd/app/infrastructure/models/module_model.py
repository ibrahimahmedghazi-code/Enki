from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.infrastructure.models import Base
import uuid

class Module(Base):
    __tablename__ = "modules"

    moduleid = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    courseid = Column(UUID(as_uuid=True), ForeignKey("courses.courseid", ondelete="CASCADE"), nullable=False)
    numberofmodule = Column(Integer)

    # Relationships ↕
    course = relationship("Course", back_populates="modules")
    lectures = relationship("Lecture", back_populates="module", cascade="all, delete")
