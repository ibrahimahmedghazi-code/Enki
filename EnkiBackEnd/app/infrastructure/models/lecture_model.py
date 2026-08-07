from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.infrastructure.models import Base
import uuid

class Lecture(Base):
    __tablename__ = "lectures"

    lectureid = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    moduleid = Column(UUID(as_uuid=True), ForeignKey("modules.moduleid", ondelete="CASCADE"), nullable=False)
    lectureorder = Column(Integer)
    lectureurl = Column(String(500))
    title = Column(String(255))
    durationminutes = Column(Integer)
    isitvideo = Column(Boolean)

    # Relationship →
    module = relationship("Module", back_populates="lectures")
