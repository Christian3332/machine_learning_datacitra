import cv2
import numpy as np
import tensorflow as tf

from utils.config import TINGGI, LEBAR
from utils.model_utils import ambil_backbone


def hitung_heatmap(model, x, indeks_kelas):
    backbone = ambil_backbone(model)
    gap = model.get_layer("gap")
    dense = model.get_layer("prediksi")

    with tf.GradientTape() as tape:
        fitur = backbone(x, training=False)
        tape.watch(fitur)
        # Pakai nilai sebelum softmax supaya gradien tidak hilang saat confidence tinggi
        logit = tf.matmul(gap(fitur), dense.kernel) + dense.bias
        skor = logit[:, indeks_kelas]

    grad = tape.gradient(skor, fitur)
    bobot = tf.reduce_mean(grad, axis=(1, 2))
    cam = tf.reduce_sum(fitur[0] * bobot[0], axis=-1)
    cam = tf.nn.relu(cam).numpy()
    if cam.max() > 0:
        cam = cam / cam.max()
    return cam


def buat_overlay(cam, crop, posisi):
    atas, kiri, tinggi, lebar = posisi
    cam = cv2.resize(cam, (LEBAR, TINGGI))
    cam = cam[atas:atas + tinggi, kiri:kiri + lebar]
    cam = cv2.resize(cam, (crop.shape[1], crop.shape[0]))

    heatmap = cv2.applyColorMap(np.uint8(255 * cam), cv2.COLORMAP_JET)
    dasar = cv2.cvtColor(crop, cv2.COLOR_GRAY2BGR)
    return cv2.addWeighted(dasar, 0.55, heatmap, 0.45, 0)
