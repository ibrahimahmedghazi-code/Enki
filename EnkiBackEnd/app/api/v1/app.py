from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.api.v1.public_router import router as public_router
from app.api.v1.admin_router import router as admin_router
from app.api.v1.user_router import router as user_router


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(public_router, prefix="/api/v1")
app.include_router(admin_router, prefix="/api/v1")
app.include_router(user_router, prefix="/api/v1")


app.mount("/media/videos", StaticFiles(directory="media/videos"), name="videos")
app.mount("/media/articles", StaticFiles(directory="media/articles"), name="articles")
app.mount("/media/images", StaticFiles(directory="media/images"), name="images")
