from fastapi import APIRouter, Depends, Query, HTTPException, Request
from fastapi.responses import StreamingResponse, Response
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, desc
from sqlalchemy.orm import selectinload
from pydantic import BaseModel
from uuid import UUID
from typing import Optional
from pathlib import Path
import os

from app.infrastructure.repositories.deps import get_db
from app.infrastructure.models.course_model import Course
from app.infrastructure.models.module_model import Module
from app.infrastructure.models.lecture_model import Lecture
from app.infrastructure.models.user_model import User
from app.infrastructure.models.user_activate_model import UserActivate
from app.infrastructure.models.user_progress_model import UserProgress

router = APIRouter()

VIDEOS_DIR = Path("media/videos")
ARTICLES_DIR = Path("media/articles")


# ── helpers ──────────────────────────────────────────────────────────
def _serialize_course(c, enrolledat=None, lastwatchedat=None):
    return {
        "courseid": str(c.courseid),
        "title": c.title,
        "author": c.author,
        "description": c.description,
        "category": c.category,
        "stage": c.stage,
        "imagepath": c.imagepath,
        "rating": c.rating,
        "enrolledat": enrolledat,
        "lastwatchedat": lastwatchedat,
        "modules": [
            {
                "moduleid": str(m.moduleid),
                "numberofmodule": m.numberofmodule,
                "lectures": [
                    {
                        "lectureid": str(l.lectureid),
                        "title": l.title,
                        "lectureorder": l.lectureorder,
                        "durationminutes": l.durationminutes,
                        "isitvideo": l.isitvideo,
                        "lectureurl": l.lectureurl,
                    }
                    for l in m.lectures
                ],
            }
            for m in c.modules
        ],
    }


# ══════════════════════════════════════════════════════════════════════
# STREAMING ENDPOINTS — Range request support for media_kit on Android
# ══════════════════════════════════════════════════════════════════════

@router.get("/stream/video/{filename}")
async def stream_video(filename: str, request: Request):
    file_path = VIDEOS_DIR / filename
    if not file_path.exists() or not file_path.is_file():
        raise HTTPException(status_code=404, detail="Video not found.")

    file_size = file_path.stat().st_size
    range_header = request.headers.get("Range")

    ext = file_path.suffix.lower()
    content_type = {
        ".mp4": "video/mp4",
        ".webm": "video/webm",
        ".mov": "video/quicktime",
        ".mkv": "video/x-matroska",
    }.get(ext, "video/mp4")

    if range_header:
        range_val = range_header.replace("bytes=", "")
        parts = range_val.split("-")
        start = int(parts[0]) if parts[0] else 0
        end = int(parts[1]) if len(parts) > 1 and parts[1] else file_size - 1
        end = min(end, file_size - 1)
        chunk_size = end - start + 1

        def iter_range():
            with open(file_path, "rb") as f:
                f.seek(start)
                remaining = chunk_size
                while remaining > 0:
                    chunk = f.read(min(65536, remaining))
                    if not chunk:
                        break
                    remaining -= len(chunk)
                    yield chunk

        return StreamingResponse(
            iter_range(),
            status_code=206,
            headers={
                "Content-Range": f"bytes {start}-{end}/{file_size}",
                "Accept-Ranges": "bytes",
                "Content-Length": str(chunk_size),
                "Content-Type": content_type,
            },
            media_type=content_type,
        )

    def iter_full():
        with open(file_path, "rb") as f:
            while chunk := f.read(65536):
                yield chunk

    return StreamingResponse(
        iter_full(),
        status_code=200,
        headers={
            "Accept-Ranges": "bytes",
            "Content-Length": str(file_size),
            "Content-Type": content_type,
        },
        media_type=content_type,
    )


@router.get("/stream/article/{filename}")
async def stream_article(filename: str):
    file_path = ARTICLES_DIR / filename
    if not file_path.exists() or not file_path.is_file():
        raise HTTPException(status_code=404, detail="Article not found.")

    return Response(
        content=file_path.read_text(encoding="utf-8"),
        media_type="text/markdown",
    )


# ── Get top 10 courses by rating ─────────────────────────────────────
@router.get("/courses/top")
async def top_courses(db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Course)
        .options(selectinload(Course.modules).selectinload(Module.lectures))
        .order_by(desc(Course.rating))
        .limit(10)
    )
    return [_serialize_course(c) for c in result.scalars().all()]


# ── Search courses with optional category filter ──────────────────────
@router.get("/courses/search")
async def search_courses(
    q: str = Query(..., min_length=1),
    category: str = Query(None),
    limit: int = Query(10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    search_term = f"%{q}%"
    conditions = [
        or_(
            Course.title.ilike(search_term),
            Course.description.ilike(search_term),
            Course.author.ilike(search_term),
        )
    ]
    if category:
        conditions.append(Course.category == category)

    result = await db.execute(
        select(Course)
        .options(selectinload(Course.modules).selectinload(Module.lectures))
        .where(*conditions)
        .order_by(desc(Course.rating))
        .limit(limit)
    )
    return [_serialize_course(c) for c in result.scalars().all()]


# ── Search users ──────────────────────────────────────────────────────
@router.get("/users/search")
async def search_users(
    q: str = Query(..., min_length=1),
    limit: int = Query(10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    search_term = f"%{q}%"
    result = await db.execute(
        select(User)
        .where(
            or_(
                User.fullname.ilike(search_term),
                User.speciality.ilike(search_term),
                User.userdescription.ilike(search_term),
            )
        )
        .limit(limit)
    )
    return [
        {
            "userid": str(u.userid),
            "fullname": u.fullname,
            "workat": u.workat,
            "age": u.age,
            "userdescription": u.userdescription,
            "speciality": u.speciality,
            "profilepicturepath": u.profilepicturepath,
        }
        for u in result.scalars().all()
    ]


# ── Top beginner courses ──────────────────────────────────────────────
@router.get("/courses/beginner/top")
async def top_beginner_courses(
    limit: int = Query(10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Course)
        .options(selectinload(Course.modules).selectinload(Module.lectures))
        .where(Course.stage == "Beginner")
        .order_by(desc(Course.rating))
        .limit(limit)
    )
    return [_serialize_course(c) for c in result.scalars().all()]


# ── Last 10 courses watched by a user ────────────────────────────────
@router.get("/users/{userid}/courses/watched")
async def user_watched_courses(
    userid: str,
    limit: int = Query(10, ge=1, le=50),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserActivate)
        .options(
            selectinload(UserActivate.course)
            .selectinload(Course.modules)
            .selectinload(Module.lectures)
        )
        .where(UserActivate.userid == userid)
        .order_by(desc(UserActivate.lastwatchedat))
        .limit(limit)
    )
    courses = []
    for ua in result.scalars().all():
        if ua.course:
            courses.append(
                _serialize_course(
                    ua.course,
                    enrolledat=ua.enrolledat.isoformat() if ua.enrolledat is not None else None,
                    lastwatchedat=ua.lastwatchedat.isoformat() if ua.lastwatchedat is not None else None,
                )
            )
    return courses


# ── Get or create user ────────────────────────────────────────────────
@router.post("/users/{userid}")
async def get_or_create_user(userid: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.userid == userid))
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


# ── Update user profile ───────────────────────────────────────────────
class UpdateUserRequest(BaseModel):
    fullname: Optional[str] = None
    workat: Optional[str] = None
    age: Optional[int] = None
    userdescription: Optional[str] = None
    speciality: Optional[str] = None
    profilepicturepath: Optional[str] = None


@router.put("/users/{userid}")
async def update_user(
    userid: UUID,
    data: UpdateUserRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(User).where(User.userid == userid))
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    if data.fullname is not None:
        user.fullname = data.fullname
    if data.workat is not None:
        user.workat = data.workat
    if data.age is not None:
        user.age = data.age
    if data.userdescription is not None:
        user.userdescription = data.userdescription
    if data.speciality is not None:
        user.speciality = data.speciality
    if data.profilepicturepath is not None:
        user.profilepicturepath = data.profilepicturepath

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


# ── Enroll user in a course ───────────────────────────────────────────
@router.post("/users/{userid}/enroll/{courseid}")
async def enroll_user(
    userid: UUID,
    courseid: UUID,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserActivate).where(
            UserActivate.userid == userid,
            UserActivate.courseid == courseid,
        )
    )
    existing = result.scalar_one_or_none()

    if not existing:
        enrollment = UserActivate(userid=userid, courseid=courseid)
        db.add(enrollment)
        await db.commit()
        return {"enrolled": True, "new": True}

    return {"enrolled": True, "new": False}


# ── Progress endpoints ────────────────────────────────────────────────
class MarkLectureRequest(BaseModel):
    userid: UUID
    courseid: UUID
    moduleid: UUID
    lectureid: UUID
    isfinished: bool


@router.post("/progress/mark")
async def mark_lecture(
    data: MarkLectureRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserProgress).where(
            UserProgress.userid == data.userid,
            UserProgress.lectureid == data.lectureid,
        )
    )
    progress = result.scalar_one_or_none()

    if progress:
        progress.isfinished = data.isfinished
    else:
        progress = UserProgress(
            userid=data.userid,
            courseid=data.courseid,
            moduleid=data.moduleid,
            lectureid=data.lectureid,
            isfinished=data.isfinished,
        )
        db.add(progress)

    await db.commit()
    return {"success": True, "isfinished": data.isfinished}


@router.get("/progress/{userid}/{courseid}")
async def get_course_progress(
    userid: UUID,
    courseid: UUID,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserProgress).where(
            UserProgress.userid == userid,
            UserProgress.courseid == courseid,
            UserProgress.isfinished == True,
        )
    )
    return {
        "finished_lecture_ids": [str(p.lectureid) for p in result.scalars().all()]
    }


# ── Update lecture URL ────────────────────────────────────────────────
class UpdateLectureUrlRequest(BaseModel):
    lectureurl: str


@router.put("/lectures/{lectureid}/url")
async def update_lecture_url(
    lectureid: UUID,
    data: UpdateLectureUrlRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Lecture).where(Lecture.lectureid == lectureid)
    )
    lecture = result.scalar_one_or_none()
    if not lecture:
        raise HTTPException(status_code=404, detail="Lecture not found.")

    lecture.lectureurl = data.lectureurl
    await db.commit()
    return {"success": True, "lectureurl": data.lectureurl}


IMAGES_DIR = Path("media/images")
IMAGES_DIR.mkdir(parents=True, exist_ok=True) 

@router.get("/stream/image/{filename}")
async def stream_image(filename: str):
    file_path = Path("media/images") / filename
    if not file_path.exists() or not file_path.is_file():
        raise HTTPException(status_code=404, detail="Image not found.")
 
    ext = file_path.suffix.lower()
    content_type = {
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".png": "image/png",
        ".webp": "image/webp",
        ".gif": "image/gif",
    }.get(ext, "image/jpeg")
 
    return Response(
        content=file_path.read_bytes(),
        media_type=content_type,
    )

@router.put("/users/{userid}/watched/{courseid}")
async def update_last_watched(
    userid: UUID,
    courseid: UUID,
    db: AsyncSession = Depends(get_db),
):
    from datetime import datetime, timezone
    result = await db.execute(
        select(UserActivate).where(
            UserActivate.userid == userid,
            UserActivate.courseid == courseid,
        )
    )
    enrollment = result.scalar_one_or_none()
    if enrollment:
        enrollment.lastwatchedat = datetime.now(timezone.utc)
        await db.commit()
    return {"success": True}
