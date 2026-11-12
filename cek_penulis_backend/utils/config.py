from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

DATASET_DIR = BASE_DIR / "dataset"
MODEL_DIR = BASE_DIR / "model"
RESULTS_DIR = BASE_DIR / "results"

MODEL_PATH = MODEL_DIR / "penulis_efficientnetv2b0.keras"
KELAS_PATH = MODEL_DIR / "kelas.json"
METRICS_PATH = MODEL_DIR / "metrics.json"
RINGKASAN_DATASET_PATH = DATASET_DIR / "ringkasan_split.json"

GRADCAM_DIR = RESULTS_DIR / "gradcam"
CROP_DIR = RESULTS_DIR / "crop"
TRAINING_DIR = RESULTS_DIR / "training"

MODEL_NAME = "EfficientNetV2B0"
TINGGI = 128
LEBAR = 768

# Di bawah nilai ini hasil dianggap "tidak dikenali"
AMBANG_DIKENALI = 0.5

MAKS_UKURAN_FILE = 10 * 1024 * 1024
FORMAT_DIIZINKAN = {"JPEG", "PNG", "MPO"}
EKSTENSI_GAMBAR = (".jpg", ".jpeg", ".png")
