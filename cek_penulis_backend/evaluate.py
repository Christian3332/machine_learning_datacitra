import json
from datetime import datetime

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score, confusion_matrix, classification_report
from tensorflow import keras

from train import muat_folder, buat_dataset
from utils.config import DATASET_DIR, MODEL_PATH, KELAS_PATH, METRICS_PATH, TRAINING_DIR, AMBANG_DIKENALI


def simpan_confusion_matrix(cm, kelas):
    ukuran = max(8, len(kelas) * 0.3)
    plt.figure(figsize=(ukuran, ukuran * 0.85))
    plt.imshow(cm, cmap="Blues")
    plt.colorbar()
    plt.xticks(range(len(kelas)), kelas, rotation=90, fontsize=7)
    plt.yticks(range(len(kelas)), kelas, fontsize=7)
    plt.xlabel("Prediksi")
    plt.ylabel("Aktual")
    plt.title("Confusion Matrix EfficientNetV2B0 (data test)")
    plt.tight_layout()
    plt.savefig(TRAINING_DIR / "confusion_matrix.png", dpi=120)
    plt.close()


def main():
    if not MODEL_PATH.exists():
        print("Model belum ada. Jalankan train.py dulu.")
        return

    model = keras.models.load_model(MODEL_PATH)
    kelas = json.loads(KELAS_PATH.read_text())
    X_test, y_test = muat_folder(DATASET_DIR / "test", kelas)
    if len(X_test) == 0:
        print("Folder dataset/test kosong.")
        return

    prob = model.predict(buat_dataset(X_test, y_test, 16), verbose=0)
    pred = prob.argmax(axis=1)
    keyakinan = prob.max(axis=1)

    hasil = {
        "accuracy": round(float(accuracy_score(y_test, pred)), 4),
        "precision": round(float(precision_score(y_test, pred, average="macro", zero_division=0)), 4),
        "recall": round(float(recall_score(y_test, pred, average="macro", zero_division=0)), 4),
        "f1_score": round(float(f1_score(y_test, pred, average="macro", zero_division=0)), 4),
        "jumlah_data_test": int(len(y_test)),
        "jumlah_kelas": len(kelas),
        "ambang": AMBANG_DIKENALI,
        "tanggal_evaluasi": datetime.now().strftime("%Y-%m-%d %H:%M"),
    }

    print("Hasil evaluasi data test (macro average)")
    for k in ("accuracy", "precision", "recall", "f1_score"):
        print(f"  {k:10s}: {hasil[k]:.4f}")

    print("\nPengaruh ambang 'tidak dikenali'")
    print("  ambang | dikenali | akurasi saat dikenali")
    for ambang in (0.3, 0.4, 0.5, 0.6, 0.7, 0.8):
        lolos = keyakinan >= ambang
        persen = lolos.mean() * 100
        akurasi = (pred[lolos] == y_test[lolos]).mean() * 100 if lolos.any() else 0
        print(f"   {ambang:.1f}  |  {persen:5.1f}%  |  {akurasi:5.1f}%")

    lolos = keyakinan >= AMBANG_DIKENALI
    hasil["persen_dikenali"] = round(float(lolos.mean()), 4)
    hasil["akurasi_saat_dikenali"] = round(float((pred[lolos] == y_test[lolos]).mean()), 4) if lolos.any() else None

    TRAINING_DIR.mkdir(parents=True, exist_ok=True)
    simpan_confusion_matrix(confusion_matrix(y_test, pred, labels=range(len(kelas))), kelas)
    laporan = classification_report(y_test, pred, labels=range(len(kelas)), target_names=kelas, zero_division=0)
    (TRAINING_DIR / "classification_report.txt").write_text(laporan)
    METRICS_PATH.write_text(json.dumps(hasil, indent=2))

    print("\nMetrics disimpan di", METRICS_PATH)
    print("Confusion matrix disimpan di", TRAINING_DIR / "confusion_matrix.png")


if __name__ == "__main__":
    main()
