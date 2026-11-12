# Cek Penulis Backend

Backend FastAPI untuk identifikasi penulis tulisan tangan dengan EfficientNetV2B0.
Folder ini juga berisi script untuk membagi dataset, training, dan evaluasi model.

## 1. Persiapan

Gunakan Python 3.10 sampai 3.12.

```bash
cd cek_penulis_backend
python -m venv venv
venv\Scripts\activate          # Windows
source venv/bin/activate       # Linux / macOS
pip install -r requirements.txt
```

## 2. Memasukkan dataset

Siapkan folder dataset dengan satu folder untuk setiap penulis, misalnya:

```
MLA/
  A220199/
    535220199_1.jpg
    ...
  A240008/
  ...
```

Lalu bagi menjadi train, validation, dan test:

```bash
python split_dataset.py --sumber path/ke/MLA
```

Script ini akan:

- membagi gambar setiap penulis menjadi 70% train, 15% validation, dan 15% test (seed 42, jadi hasilnya selalu sama),
- membuang gambar yang isinya sama persis (dicek dengan hash MD5), supaya gambar yang sama tidak masuk ke train dan test sekaligus,
- menyimpan ringkasan pembagian di `dataset/ringkasan_split.json`.

Hasilnya:

```
dataset/
  train/A220199/ ...
  validation/A220199/ ...
  test/A220199/ ...
```

Rasio bisa diubah, contoh `python split_dataset.py --sumber MLA --val 0.1 --test 0.2`.

## 3. Training EfficientNetV2B0

```bash
python train.py
```

Opsi: `--epoch 30` (default) dan `--batch 16` (default).

Training memakai bobot ImageNet, transfer learning, augmentasi ringan (rotasi kecil, zoom, brightness),
EarlyStopping, dan ReduceLROnPlateau. Hasilnya:

| File | Isi |
|---|---|
| `model/penulis_efficientnetv2b0.keras` | Model hasil training |
| `model/kelas.json` | Urutan nama penulis sesuai output model |
| `results/training/grafik_training.png` | Grafik accuracy dan loss |
| `results/training/riwayat_training.json` | Nilai per epoch dan waktu training |

Training sangat lambat tanpa GPU. Kalau laptop tidak punya GPU NVIDIA, jalankan di Google Colab (lihat bagian 5).

## 4. Evaluasi

```bash
python evaluate.py
```

Script ini menghitung accuracy, precision, recall, dan F1-score (macro) pada data test, lalu menyimpan:

| File | Isi |
|---|---|
| `model/metrics.json` | Nilai evaluasi, dibaca oleh halaman Tentang Model di aplikasi |
| `results/training/confusion_matrix.png` | Confusion matrix |
| `results/training/classification_report.txt` | Nilai per penulis |

Script juga menampilkan tabel pengaruh ambang "tidak dikenali". Pakai tabel itu untuk memilih nilai
`AMBANG_DIKENALI` di `utils/config.py` (default 0.5).

## 5. Training di Google Colab

1. Upload `CekPenulis.zip` dan zip dataset ke Google Drive.
2. Buat notebook baru, pilih Runtime > Change runtime type > T4 GPU.
3. Jalankan cell berikut (sesuaikan lokasi file di Drive):

```python
from google.colab import drive
drive.mount('/content/drive')

!unzip -q /content/drive/MyDrive/CekPenulis.zip -d /content
!unzip -q /content/drive/MyDrive/MLA/Dataset_Tulis_Tangan_Mahasiswa.zip -d /content/data
%cd /content/cek_penulis_backend

!python split_dataset.py --sumber /content/data/MLA
!python train.py
!python evaluate.py

!zip -r /content/drive/MyDrive/model_cek_penulis.zip model results/training
```

Colab sudah punya TensorFlow, OpenCV, scikit-learn, dan Matplotlib, jadi tidak perlu `pip install`.
Setelah selesai, ekstrak `model_cek_penulis.zip` dari Drive ke folder backend di laptop
sehingga file `model/penulis_efficientnetv2b0.keras`, `model/kelas.json`, dan `model/metrics.json` ada di tempatnya.

## 6. Menjalankan API

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

`--host 0.0.0.0` diperlukan supaya HP di jaringan Wi-Fi yang sama bisa mengakses server.
Buka `http://localhost:8000/docs` untuk mencoba endpoint langsung dari browser.

Kalau model diganti atau dilatih ulang, restart server supaya model baru dimuat.

### Endpoint

| Method | Endpoint | Fungsi |
|---|---|---|
| POST | `/api/identify` | Kirim gambar (form-data, field `file`), dapat hasil identifikasi |
| GET | `/api/model-info` | Info model, jumlah kelas, dataset, dan nilai evaluasi |
| GET | `/api/health` | Cek server dan ketersediaan model |
| GET | `/results/...` | Gambar Grad-CAM dan crop hasil identifikasi |

Contoh respons `/api/identify`:

```json
{
  "success": true,
  "status": "recognized",
  "predicted_writer": "A250014",
  "confidence": 0.87,
  "top_predictions": [
    {"writer_id": "A250014", "confidence": 0.87},
    {"writer_id": "A250029", "confidence": 0.06},
    {"writer_id": "A240037", "confidence": 0.03}
  ],
  "threshold": 0.5,
  "gradcam_url": "/results/gradcam/xxxx.jpg",
  "crop_url": "/results/crop/xxxx.jpg",
  "processing_time": 0.4,
  "model_name": "EfficientNetV2B0"
}
```

Angka di atas hanya contoh format. Jika confidence tertinggi di bawah ambang, `status` bernilai
`not_recognized` dan `predicted_writer` bernilai `null`.

Respons error selalu berbentuk `{"success": false, "message": "..."}`:

| Kode | Penyebab |
|---|---|
| 400 | File kosong atau bukan gambar JPG/JPEG/PNG |
| 413 | File lebih dari 10 MB |
| 503 | Model belum ada (train.py belum dijalankan) |
| 500 | Kesalahan saat memproses gambar atau error server |

## 7. Alur preprocessing

Training, evaluasi, dan API memakai fungsi yang sama di `utils/preprocess.py`, jadi gambar yang
diproses saat prediksi diperlakukan sama persis dengan saat training:

1. Gambar dibuka, rotasi EXIF dari kamera HP dirapikan, lalu diubah ke grayscale.
2. Cahaya diratakan supaya foto berbayang mirip hasil scan.
3. Area tulisan dicari dengan threshold Otsu, lalu di-crop.
4. Warna dibalik (tinta putih, latar hitam) dan diperkecil tanpa merusak rasio ke 128 x 768 piksel.

Grad-CAM dihitung dari lapisan konvolusi terakhir EfficientNetV2B0 terhadap kelas dengan
confidence tertinggi, lalu ditumpuk di atas gambar hasil crop.

## Struktur folder

```
cek_penulis_backend/
  main.py              aplikasi FastAPI
  routes/identify.py   endpoint API
  services/            prediksi dan Grad-CAM
  utils/               config, preprocessing, model, validasi gambar
  model/               model hasil training (kosong sebelum training)
  results/             hasil Grad-CAM, crop, dan grafik training
  dataset/             hasil split_dataset.py
  split_dataset.py
  train.py
  evaluate.py
  requirements.txt
```
