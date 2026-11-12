# Cek Penulis

Aplikasi identifikasi penulis tulisan tangan dengan EfficientNetV2B0.

```
HP (Flutter)  --foto-->  Backend (FastAPI + EfficientNetV2B0)  --hasil + Grad-CAM-->  HP
```

| Folder | Isi |
|---|---|
| `cek_penulis_flutter/` | Aplikasi Android (Flutter) |
| `cek_penulis_backend/` | API FastAPI, script split dataset, training, dan evaluasi |

## Status paket ini

Model **belum dilatih** di dalam paket ini, jadi folder `cek_penulis_backend/model/` masih kosong.
Training EfficientNetV2B0 dengan bobot ImageNet butuh GPU, jadi harus dijalankan sendiri
(disarankan di Google Colab). Sebelum model ada, endpoint `/api/identify` akan menjawab
"Model belum tersedia" dan halaman Tentang Model menampilkan "Belum tersedia".

Yang sudah diuji:

- `split_dataset.py` dengan dataset asli (50 penulis, 2.690 gambar, 5 gambar duplikat dibuang)
- alur `train.py` dan `evaluate.py` dengan subset kecil
- semua endpoint API, termasuk Grad-CAM dan penanganan error

Kode Flutter belum dikompilasi di lingkungan pembuatan paket ini, jadi jalankan `flutter run`
dan laporkan kalau ada error.

## Urutan menjalankan

1. **Install backend**: `pip install -r requirements.txt` di folder backend.
2. **Bagi dataset**: `python split_dataset.py --sumber path/ke/MLA`
3. **Training**: `python train.py` (atau di Colab, lihat README backend bagian 5)
4. **Evaluasi**: `python evaluate.py`
5. **Jalankan API**: `uvicorn main:app --host 0.0.0.0 --port 8000`
6. **Jalankan aplikasi**: di folder Flutter, `flutter create --project-name cek_penulis --platforms android,ios .`,
   lalu `flutter pub get` dan `flutter run`
7. **Hubungkan**: di aplikasi, tekan ikon gear dan isi alamat server.

Detail tiap langkah ada di `cek_penulis_backend/README.md` dan `cek_penulis_flutter/README.md`.

## Mengganti dataset

Cukup siapkan folder baru berisi satu folder per penulis, lalu ulangi langkah 2 sampai 5.
Jumlah kelas, nama penulis, dan nilai evaluasi di aplikasi akan mengikuti model yang baru.
Untuk menyamarkan identitas, ganti nama folder penulis (misalnya NIM menjadi W01 sampai W50)
sebelum menjalankan `split_dataset.py`.

## Batasan

- Aplikasi hanya mengenali penulis yang ada di dataset saat training.
- Hasil berupa perkiraan dengan tingkat keyakinan, bukan alat bukti yang pasti.
- Model mengenali gaya tulisan, tidak membaca isi tulisan. OCR belum tersedia.
- Satu penulis menulis beberapa baris dari halaman yang sama, sehingga baris dari halaman yang sama
  bisa masuk ke train dan test. Gambar yang sama persis sudah dibuang, tapi hal ini perlu disebut
  di bagian batasan laporan.
