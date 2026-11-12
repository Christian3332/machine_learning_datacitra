from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles

from routes.identify import router
from services.predictor import model_tersedia, muat_model
from utils.config import RESULTS_DIR, GRADCAM_DIR, CROP_DIR


@asynccontextmanager
async def lifespan(app):
    GRADCAM_DIR.mkdir(parents=True, exist_ok=True)
    CROP_DIR.mkdir(parents=True, exist_ok=True)
    if model_tersedia():
        muat_model()
        print("Model berhasil dimuat")
    else:
        print("Model belum ada. Jalankan train.py agar endpoint /api/identify bisa dipakai.")
    yield


app = FastAPI(title="Cek Penulis API", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(Exception)
async def error_server(request: Request, exc: Exception):
    print("Error server:", repr(exc))
    return JSONResponse(status_code=500, content={"success": False, "message": "Terjadi kesalahan di server."})


app.include_router(router)
app.mount("/results", StaticFiles(directory=RESULTS_DIR), name="results")


@app.get("/")
def beranda():
    return {"success": True, "message": "Cek Penulis API berjalan. Buka /docs untuk mencoba endpoint."}
