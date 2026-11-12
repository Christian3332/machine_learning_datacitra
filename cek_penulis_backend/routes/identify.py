from fastapi import APIRouter, File, UploadFile
from fastapi.concurrency import run_in_threadpool
from fastapi.responses import JSONResponse

from services.predictor import identifikasi, info_model, model_tersedia, ModelBelumTersedia
from utils.config import MAKS_UKURAN_FILE
from utils.image_check import gambar_valid

router = APIRouter(prefix="/api")


def gagal(kode, pesan):
    return JSONResponse(status_code=kode, content={"success": False, "message": pesan})


@router.get("/health")
def health():
    return {"success": True, "model_available": model_tersedia()}


@router.get("/model-info")
def model_info():
    return info_model()


@router.post("/identify")
async def identify(file: UploadFile = File(...)):
    isi = await file.read(MAKS_UKURAN_FILE + 1)
    if len(isi) == 0:
        return gagal(400, "File gambar kosong.")
    if len(isi) > MAKS_UKURAN_FILE:
        return gagal(413, "Ukuran file terlalu besar. Maksimal 10 MB.")
    if not gambar_valid(isi):
        return gagal(400, "File bukan gambar yang valid. Gunakan JPG, JPEG, atau PNG.")
    if not model_tersedia():
        return gagal(503, "Model belum tersedia. Jalankan train.py terlebih dahulu.")

    try:
        return await run_in_threadpool(identifikasi, isi)
    except ModelBelumTersedia:
        return gagal(503, "Model belum tersedia. Jalankan train.py terlebih dahulu.")
    except Exception as e:
        print("Error saat prediksi:", repr(e))
        return gagal(500, "Terjadi masalah saat memproses gambar. Coba foto lain.")
