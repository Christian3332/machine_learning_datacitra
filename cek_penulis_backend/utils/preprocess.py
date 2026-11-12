import cv2
import numpy as np
from PIL import Image, ImageOps

from utils.config import TINGGI, LEBAR


def buka_gambar(sumber):
    img = Image.open(sumber)
    img = ImageOps.exif_transpose(img)
    gray = np.array(img.convert("L"))

    sisi_terpanjang = max(gray.shape)
    if sisi_terpanjang > 2000:
        skala = 2000 / sisi_terpanjang
        gray = cv2.resize(gray, None, fx=skala, fy=skala, interpolation=cv2.INTER_AREA)
    return gray


def ratakan_cahaya(gray):
    # Latar kertas diperkirakan dengan median blur lalu dibagi,
    # supaya foto yang bayangannya tidak rata jadi mirip hasil scan
    latar = cv2.medianBlur(gray, 31)
    return cv2.divide(gray, latar, scale=255)


def cari_area_tulisan(gray):
    _, mask = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)
    tinta = mask > 0
    h, w = gray.shape

    baris = np.where(tinta.sum(axis=1) > max(2, 0.002 * w))[0]
    kolom = np.where(tinta.sum(axis=0) > max(2, 0.002 * h))[0]
    if len(baris) == 0 or len(kolom) == 0:
        return 0, h, 0, w

    jarak = 4
    y1 = max(0, baris[0] - jarak)
    y2 = min(h, baris[-1] + jarak + 1)
    x1 = max(0, kolom[0] - jarak)
    x2 = min(w, kolom[-1] + jarak + 1)
    return y1, y2, x1, x2


def siapkan_input(crop):
    h, w = crop.shape
    skala = min(TINGGI / h, LEBAR / w)
    tinggi_baru = max(1, round(h * skala))
    lebar_baru = max(1, round(w * skala))
    cara = cv2.INTER_AREA if skala < 1 else cv2.INTER_LINEAR
    kecil = cv2.resize(255 - crop, (lebar_baru, tinggi_baru), interpolation=cara)

    kanvas = np.zeros((TINGGI, LEBAR), dtype=np.uint8)
    atas = (TINGGI - tinggi_baru) // 2
    kiri = (LEBAR - lebar_baru) // 2
    kanvas[atas:atas + tinggi_baru, kiri:kiri + lebar_baru] = kecil
    return kanvas, (atas, kiri, tinggi_baru, lebar_baru)


def proses_gambar(sumber):
    gray = ratakan_cahaya(buka_gambar(sumber))
    y1, y2, x1, x2 = cari_area_tulisan(gray)
    crop = gray[y1:y2, x1:x2]
    masukan, posisi = siapkan_input(crop)
    return crop, masukan, posisi


def ke_batch(masukan):
    x = np.repeat(masukan[None, :, :, None], 3, axis=-1)
    return x.astype("float32")
