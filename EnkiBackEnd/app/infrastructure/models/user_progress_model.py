from sqlalchemy import Column, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.infrastructure.models import Base
import uuid

class UserProgress(Base):
    __tablename__ = "userprogress"

    progressid = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    userid = Column(UUID(as_uuid=True), ForeignKey("users.userid", ondelete="CASCADE"), nullable=False)
    courseid = Column(UUID(as_uuid=True), ForeignKey("courses.courseid", ondelete="CASCADE"), nullable=False)
    moduleid = Column(UUID(as_uuid=True), ForeignKey("modules.moduleid", ondelete="CASCADE"), nullable=False)
    lectureid = Column(UUID(as_uuid=True), ForeignKey("lectures.lectureid", ondelete="CASCADE"), nullable=False)
    isfinished = Column(Boolean, default=False)
