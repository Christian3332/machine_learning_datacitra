import io
import json
import time
import uuid

import cv2
import numpy as np
from tensorflow import keras

from services.gradcam import hitung_heatmap, buat_overlay
from utils.config import (
    MODEL_PATH, KELAS_PATH, METRICS_PATH, RINGKASAN_DATASET_PATH,
    GRADCAM_DIR, CROP_DIR, MODEL_NAME, AMBANG_DIKENALI,
)
from utils.preprocess import proses_gambar, ke_batch

model = None
daftar_kelas = None


class ModelBelumTersedia(Exception):
    pass


def model_tersedia():
    return MODEL_PATH.exists() and KELAS_PATH.exists()


def muat_model():
    global model, daftar_kelas
    if model is None:
        if not model_tersedia():
            raise ModelBelumTersedia()
        model = keras.models.load_model(MODEL_PATH)
        daftar_kelas = json.loads(KELAS_PATH.read_text())
        # Prediksi pertama biasanya lambat, jadi dipanaskan dulu saat server mulai
        model.predict(np.zeros((1,) + model.input_shape[1:], dtype="float32"), verbose=0)
    return model, daftar_kelas


def simpan_gambar(gambar, folder, nama):
    lebar_maks = 1200
    if gambar.shape[1] > lebar_maks:
        skala = lebar_maks / gambar.shape[1]
        gambar = cv2.resize(gambar, None, fx=skala, fy=skala, interpolation=cv2.INTER_AREA)
    folder.mkdir(parents=True, exist_ok=True)
    cv2.imwrite(str(folder / nama), gambar, [cv2.IMWRITE_JPEG_QUALITY, 90])


def identifikasi(isi_file):
    model, kelas = muat_model()

    mulai = time.time()
    crop, masukan, posisi = proses_gambar(io.BytesIO(isi_file))
    x = ke_batch(masukan)
    prob = model.predict(x, verbose=0)[0]
    waktu_prediksi = time.time() - mulai

    urutan = np.argsort(prob)[::-1][:3]
    top = [
        {"writer_id": kelas[i], "confidence": round(float(prob[i]), 4)}
        for i in urutan
    ]
    dikenali = top[0]["confidence"] >= AMBANG_DIKENALI

    cam = hitung_heatmap(model, x, int(urutan[0]))
    overlay = buat_overlay(cam, crop, posisi)

    nama_file = uuid.uuid4().hex + ".jpg"
    simpan_gambar(overlay, GRADCAM_DIR, nama_file)
    simpan_gambar(crop, CROP_DIR, nama_file)

    return {
        "success": True,
        "status": "recognized" if dikenali else "not_recognized",
        "predicted_writer": top[0]["writer_id"] if dikenali else None,
        "confidence": top[0]["confidence"],
        "top_predictions": top,
        "threshold": AMBANG_DIKENALI,
        "gradcam_url": f"/results/gradcam/{nama_file}",
        "crop_url": f"/results/crop/{nama_file}",
        "processing_time": round(waktu_prediksi, 3),
        "model_name": MODEL_NAME,
    }


def baca_json(path):
    if path.exists():
        return json.loads(path.read_text())
    return None


def info_model():
    kelas = baca_json(KELAS_PATH)
    metrics = baca_json(METRICS_PATH)
    ringkasan = baca_json(RINGKASAN_DATASET_PATH)

    if metrics is None:
        nilai = None
    else:
        nilai = {k: metrics[k] for k in ("accuracy", "precision", "recall", "f1_score")}

    dataset = None
    if ringkasan is not None:
        dataset = {
            "train": ringkasan["total"]["train"],
            "validation": ringkasan["total"]["validation"],
            "test": ringkasan["total"]["test"],
        }

    return {
        "success": True,
        "model_name": MODEL_NAME,
        "model_available": model_tersedia(),
        "num_classes": len(kelas) if kelas else None,
        "threshold": AMBANG_DIKENALI,
        "dataset": dataset,
        "metrics": nilai,
    }
