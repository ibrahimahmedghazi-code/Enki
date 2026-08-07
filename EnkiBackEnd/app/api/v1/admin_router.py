from fastapi import APIRouter, Depends, UploadFile, File, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from pathlib import Path
import shutil, uuid, os
from pydantic import BaseModel

from app.infrastructure.repositories.deps import get_db
from app.infrastructure.models.course_model import Course
from app.infrastructure.models.module_model import Module
from app.infrastructure.models.lecture_model import Lecture
from app.domain.schemas.course import CourseCreateSchema

router = APIRouter()

VIDEOS_DIR = Path("media/videos")
VIDEOS_DIR.mkdir(parents=True, exist_ok=True)

ARTICLES_DIR = Path("media/articles")
ARTICLES_DIR.mkdir(parents=True, exist_ok=True)

BASE_URL = os.getenv("BASE_URL", "http://localhost:8000")


# ── Create course — returns full structure with lecture IDs ───────────
@router.post("/courses/create")
async def create_course(data: CourseCreateSchema, db: AsyncSession = Depends(get_db)):
    course_id = uuid.uuid4()
    course = Course(
        courseid=course_id,
        title=data.title,
        author=data.author,
        description=data.description,
        category=data.category,
        stage=data.stage,
        imagepath=data.image_path,
        rating=data.rating,
    )
    db.add(course)
    await db.flush()

    result_modules = []
    for mod_data in data.modules:
        module_id = uuid.uuid4()
        module = Module(
            moduleid=module_id,
            courseid=course_id,
            numberofmodule=mod_data.number_of_module,
        )
        db.add(module)
        await db.flush()

        result_lectures = []
        for lec_data in mod_data.lectures:
            lecture_id = uuid.uuid4()
            lecture = Lecture(
                lectureid=lecture_id,
                moduleid=module_id,
                title=lec_data.title,
                lectureorder=lec_data.lecture_order,
                durationminutes=lec_data.duration_minutes,
                isitvideo=lec_data.is_it_video,
                lectureurl=None,
            )
            db.add(lecture)
            # Return lecture ID so portal can link files to it
            result_lectures.append({
                "lectureid": str(lecture_id),
                "title": lec_data.title,
                "is_it_video": lec_data.is_it_video,
            })

        result_modules.append({
            "moduleid": str(module_id),
            "number_of_module": mod_data.number_of_module,
            "lectures": result_lectures,
        })

    await db.commit()

    return {
        "courseid": str(course_id),
        "title": data.title,
        "modules": result_modules,  # ← portal uses these IDs to link files
    }


# ── Upload video ──────────────────────────────────────────────────────
@router.post("/upload/video/{course_id}")
async def upload_video(course_id: str, file: UploadFile = File(...), db: AsyncSession = Depends(get_db)):
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided.")
    ext = Path(file.filename).suffix.lower()
    if ext not in {".mp4", ".mov", ".webm", ".mkv"}:
        raise HTTPException(status_code=400, detail="Video files only.")

    filename = f"{uuid.uuid4()}{ext}"
    dest = VIDEOS_DIR / filename
    with dest.open("wb") as buf:
        shutil.copyfileobj(file.file, buf)

    # Store only the filename — Flutter builds the full URL dynamically
    return {"url": filename, "filename": filename}


# ── Upload markdown ───────────────────────────────────────────────────
@router.post("/upload/markdown/{course_id}")
async def upload_markdown(course_id: str, file: UploadFile = File(...), db: AsyncSession = Depends(get_db)):
    if not file.filename or not file.filename.endswith(".md"):
        raise HTTPException(status_code=400, detail="Only .md files allowed.")

    filename = f"{uuid.uuid4()}.md"
    dest = ARTICLES_DIR / filename
    with dest.open("wb") as buf:
        shutil.copyfileobj(file.file, buf)

    # Store only the filename
    return {"url": filename, "filename": filename}


# ── Save URL to lecture after upload ──────────────────────────────────
class UpdateLectureUrlRequest(BaseModel):
    lectureurl: str


@router.put("/lectures/{lectureid}/url")
async def update_lecture_url(
    lectureid: uuid.UUID,
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



# ── List all media files ──────────────────────────────────────────────
@router.get("/media/list")
async def list_all_media():
    files = []

    IMAGES_DIR = Path("media/images")
    for f in sorted(IMAGES_DIR.iterdir()):
        if f.is_file() and f.suffix.lower() in {".jpg", ".jpeg", ".png", ".webp", ".gif"}:
            files.append({
                 "filename": f.name,
                 "size_bytes": f.stat().st_size,
                 "url": f"{BASE_URL}/api/v1/stream/image/{f.name}",
                 "type": "image"
         })
    for f in sorted(VIDEOS_DIR.iterdir()):
        if f.is_file() and f.suffix.lower() in {".mp4", ".mov", ".webm", ".mkv"}:
            files.append({
                "filename": f.name,
                "size_bytes": f.stat().st_size,
                "url": f"{BASE_URL}/media/videos/{f.name}",
                "type": "video"
            })

    for f in sorted(ARTICLES_DIR.iterdir()):
        if f.is_file() and f.suffix.lower() == ".md":
            files.append({
                "filename": f.name,
                "size_bytes": f.stat().st_size,
                "url": f"{BASE_URL}/media/articles/{f.name}",
                "type": "article"
            })

    return files

IMAGES_DIR = Path("media/images")
IMAGES_DIR.mkdir(parents=True, exist_ok=True)
 
 
@router.post("/upload/image")
async def upload_image(
    file: UploadFile = File(...),
    db: AsyncSession = Depends(get_db),
):
    """Upload any image — course thumbnail or profile picture."""
    if not file.filename:
        raise HTTPException(status_code=400, detail="No filename provided.")
 
    ext = Path(file.filename).suffix.lower()
    if ext not in {".jpg", ".jpeg", ".png", ".webp", ".gif"}:
        raise HTTPException(status_code=400, detail="Image files only.")
 
    filename = f"{uuid.uuid4()}{ext}"
    dest = IMAGES_DIR / filename
    with dest.open("wb") as buf:
        shutil.copyfileobj(file.file, buf)
 
    # Return just the filename — Flutter builds full URL dynamically
    return {"filename": filename}
