# Cek Penulis (Flutter)

Aplikasi Android untuk mengidentifikasi penulis dari foto tulisan tangan.
Gambar dikirim ke backend FastAPI, lalu model EfficientNetV2B0 di backend memberi hasilnya.

## Kebutuhan

- Flutter SDK 3.24 atau lebih baru (Dart 3.5+)
- Android Studio dengan emulator, atau HP Android dengan USB debugging aktif
- Backend `cek_penulis_backend` sudah berjalan

## Cara menjalankan

Folder ini hanya berisi source code (`lib/`, `pubspec.yaml`, dan AndroidManifest yang sudah diatur).
Folder platform lainnya dibuat otomatis dengan `flutter create`:

```bash
cd cek_penulis_flutter
flutter create --project-name cek_penulis --platforms android,ios .
flutter pub get
flutter run
```

`flutter create` tidak menimpa file yang sudah ada. File
`android/app/src/main/AndroidManifest.xml` dari paket ini tetap dipakai, isinya sudah mencakup
izin internet, izin kamera, dan `usesCleartextTraffic` supaya aplikasi bisa memanggil server `http://`.

Kalau `flutter pub get` gagal karena versi package, jalankan `flutter pub upgrade --major-versions`.

## Menghubungkan ke backend

1. Jalankan backend dengan `uvicorn main:app --host 0.0.0.0 --port 8000`.
2. Di aplikasi, tekan ikon gear di kanan atas halaman Identifikasi.
3. Isi alamat server:
   - Emulator Android: `http://10.0.2.2:8000` (alamat default)
   - HP asli: `http://IP-LAPTOP:8000`, contoh `http://192.168.1.5:8000`.
     Cek IP laptop dengan `ipconfig` (Windows) atau `ifconfig` / `ip a` (Linux/macOS).
     HP dan laptop harus di Wi-Fi yang sama, dan firewall laptop harus mengizinkan port 8000.
4. Tekan Simpan. Aplikasi akan memberi tahu apakah server terhubung.

## Untuk iOS (opsional)

Tambahkan ke `ios/Runner/Info.plist` setelah menjalankan `flutter create`:

```xml
<key>NSCameraUsageDescription</key>
<string>Kamera dipakai untuk memotret tulisan tangan</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Galeri dipakai untuk memilih foto tulisan tangan</string>
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

`NSAllowsArbitraryLoads` hanya untuk pengembangan dengan server `http://`.

## Fitur

- **Identifikasi**: pilih gambar dari galeri atau kamera, pratinjau, ganti atau hapus gambar,
  lalu lihat status pengenalan, tiga prediksi teratas, Grad-CAM, dan waktu prediksi.
- **Riwayat**: hasil disimpan di HP (SharedPreferences dan folder dokumen aplikasi), lengkap dengan
  thumbnail, detail, dan tombol hapus. Kalau dijalankan di web (`flutter run -d chrome`), riwayat hanya
  disimpan di memori dan kembali kosong saat halaman di-refresh atau aplikasi di-restart.
- **Tentang Model**: penjelasan EfficientNetV2B0 dan Grad-CAM, info dataset, serta accuracy, precision,
  recall, dan F1-score dari `model/metrics.json` di backend. Kalau belum ada, tampil "Belum tersedia".

Crop dilakukan otomatis oleh backend (area tulisan dicari lalu dipotong) dan hasilnya tampil di bagian
"Hasil crop". Crop manual belum dibuat karena butuh pengaturan native tambahan.
OCR juga belum tersedia; kartunya sudah disiapkan untuk pengembangan berikutnya.

## Struktur folder

```
lib/
  main.dart
  models/      HasilIdentifikasi, RiwayatItem, InfoModel
  services/    API, riwayat lokal, pengaturan alamat server
  providers/   state halaman identifikasi dan riwayat
  screens/     identifikasi, kamera, riwayat, detail riwayat, tentang model
  widgets/     komponen tampilan
  utils/       warna, tema, format angka dan tanggal
test/
  widget_test.dart
```

Jalankan `flutter test` untuk mengecek format angka dan pembacaan respons backend.
