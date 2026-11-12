import argparse
import json
import time

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

from utils.config import DATASET_DIR, MODEL_DIR, MODEL_PATH, KELAS_PATH, TRAINING_DIR, EKSTENSI_GAMBAR
from utils.model_utils import buat_model
from utils.preprocess import proses_gambar


def daftar_kelas(folder):
    return sorted(p.name for p in folder.iterdir() if p.is_dir())


def muat_folder(folder, kelas):
    X, y = [], []
    for i, nama in enumerate(kelas):
        folder_kelas = folder / nama
        if not folder_kelas.exists():
            continue
        for f in sorted(folder_kelas.iterdir()):
            if f.suffix.lower() in EKSTENSI_GAMBAR:
                _, masukan, _ = proses_gambar(f)
                X.append(masukan)
                y.append(i)
    return np.array(X)[..., None], np.array(y)


augmentasi = keras.Sequential([
    layers.RandomRotation(0.01, fill_mode="constant"),
    layers.RandomZoom(0.1, fill_mode="constant"),
    layers.RandomBrightness(0.15, value_range=(0, 255)),
])


def ke_rgb(x, y):
    return tf.image.grayscale_to_rgb(tf.cast(x, tf.float32)), y


def buat_dataset(X, y, batch, latih=False):
    ds = tf.data.Dataset.from_tensor_slices((X, y))
    if latih:
        ds = ds.shuffle(len(X), seed=42)
    ds = ds.batch(batch).map(ke_rgb, num_parallel_calls=tf.data.AUTOTUNE)
    if latih:
        ds = ds.map(lambda a, b: (augmentasi(a, training=True), b), num_parallel_calls=tf.data.AUTOTUNE)
    return ds.prefetch(tf.data.AUTOTUNE)


def simpan_grafik(history):
    TRAINING_DIR.mkdir(parents=True, exist_ok=True)
    fig, ax = plt.subplots(1, 2, figsize=(13, 4.5))
    ax[0].plot(history["accuracy"], label="Train")
    ax[0].plot(history["val_accuracy"], label="Validation")
    ax[0].set_title("Accuracy")
    ax[1].plot(history["loss"], label="Train")
    ax[1].plot(history["val_loss"], label="Validation")
    ax[1].set_title("Loss")
    for a in ax:
        a.set_xlabel("Epoch")
        a.legend()
        a.grid(alpha=0.3)
    plt.tight_layout()
    plt.savefig(TRAINING_DIR / "grafik_training.png", dpi=120)
    plt.close()


def main():
    parser = argparse.ArgumentParser(description="Training EfficientNetV2B0 untuk identifikasi penulis")
    parser.add_argument("--epoch", type=int, default=30)
    parser.add_argument("--batch", type=int, default=16)
    parser.add_argument("--bobot", default="imagenet", choices=["imagenet", "none"],
                        help="'none' hanya untuk uji coba tanpa internet")
    args = parser.parse_args()

    keras.utils.set_random_seed(42)
    print("GPU:", tf.config.list_physical_devices("GPU"))

    kelas = daftar_kelas(DATASET_DIR / "train")
    if not kelas:
        print("Folder dataset/train masih kosong. Jalankan split_dataset.py dulu.")
        return

    print("Memuat data...")
    X_train, y_train = muat_folder(DATASET_DIR / "train", kelas)
    X_val, y_val = muat_folder(DATASET_DIR / "validation", kelas)
    print(f"Jumlah penulis: {len(kelas)} | train: {len(X_train)} | validation: {len(X_val)}")

    ds_train = buat_dataset(X_train, y_train, args.batch, latih=True)
    ds_val = buat_dataset(X_val, y_val, args.batch)

    model = buat_model(len(kelas), bobot=None if args.bobot == "none" else "imagenet")
    callback = [
        keras.callbacks.EarlyStopping(monitor="val_loss", patience=5, restore_best_weights=True),
        keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.5, patience=2, verbose=1),
    ]

    mulai = time.time()
    hist = model.fit(ds_train, validation_data=ds_val, epochs=args.epoch, callbacks=callback)
    waktu = time.time() - mulai
    print(f"Waktu training: {waktu:.1f} detik")

    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    model.save(MODEL_PATH)
    KELAS_PATH.write_text(json.dumps(kelas, indent=2))

    riwayat = {k: [float(v) for v in vals] for k, vals in hist.history.items()}
    riwayat["waktu_training_detik"] = waktu
    TRAINING_DIR.mkdir(parents=True, exist_ok=True)
    (TRAINING_DIR / "riwayat_training.json").write_text(json.dumps(riwayat, indent=2))
    simpan_grafik(hist.history)

    print("Model disimpan di", MODEL_PATH)
    print("Grafik disimpan di", TRAINING_DIR / "grafik_training.png")
    print("Lanjutkan dengan: python evaluate.py")


if __name__ == "__main__":
    main()
