from sqlalchemy import Column, ForeignKey, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.infrastructure.models import Base
import uuid
from datetime import datetime, timezone

class UserActivate(Base):
    __tablename__ = "useractivate"

    activateid = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    userid = Column(UUID(as_uuid=True), ForeignKey("users.userid", ondelete="CASCADE"), nullable=False)
    courseid = Column(UUID(as_uuid=True), ForeignKey("courses.courseid", ondelete="CASCADE"), nullable=False)
    enrolledat = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    lastwatchedat = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))

    user = relationship("User", back_populates="enrollments")
    course = relationship("Course", back_populates="enrollments")
