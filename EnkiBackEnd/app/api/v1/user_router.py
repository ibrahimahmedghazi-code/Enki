from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from uuid import UUID

from app.infrastructure.repositories.deps import get_db
from app.infrastructure.models.user_model import User

router = APIRouter()


@router.post("/users/{userid}")
async def get_or_create_user(userid: UUID, db: AsyncSession = Depends(get_db)):
    """
    Flutter sends a UUID (from Firebase Auth or device ID).
    - If user exists → return their info.
    - If not → create a default user with that UUID and return it.
    """
    result = await db.execute(
        select(User).where(User.userid == userid)
    )
    user = result.scalar_one_or_none()

    if not user:
        user = User(
            userid=userid,
            fullname="User",
            workat=None,
            age=None,
            userdescription=None,
            speciality=None,
            profilepicturepath="assets/images/app_icon.png",
        )
        db.add(user)
        await db.commit()
        await db.refresh(user)

    return {
        "userid": str(user.userid),
        "fullname": user.fullname,
        "workat": user.workat,
        "age": user.age,
        "userdescription": user.userdescription,
        "speciality": user.speciality,
        "profilepicturepath": user.profilepicturepath,
    }
