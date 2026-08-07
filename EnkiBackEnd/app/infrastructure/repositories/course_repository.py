from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.infrastructure.models.course_model import Course
from app.infrastructure.models.module_model import Module

async def get_top_10_courses(db: AsyncSession) -> list[Course]:
    result = await db.execute(
        select(Course)
        .options(
            selectinload(Course.modules).selectinload(Module.lectures)
        )
        .order_by(Course.rating.desc())
        .limit(10)
    )
    courses: list[Course] = list(result.scalars().all())
    return courses
