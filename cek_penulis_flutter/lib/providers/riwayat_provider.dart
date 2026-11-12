import 'package:flutter/foundation.dart';

import '../models/hasil_identifikasi.dart';
import '../models/riwayat_item.dart';
import '../services/api_service.dart';
import '../services/riwayat_service.dart';

/// Di web tidak ada folder dokumen aplikasi, jadi riwayat hanya disimpan di memori
/// dan kembali kosong saat halaman di-refresh atau aplikasi di-restart.
const riwayatHanyaDiMemori = kIsWeb;

class RiwayatProvider extends ChangeNotifier {
  List<RiwayatItem> daftar = [];

  Future<void> muat() async {
    if (riwayatHanyaDiMemori) return;
    daftar = await RiwayatService.muat();
    notifyListeners();
  }

  Future<void> tambah(HasilIdentifikasi hasil, Uint8List gambar, String ekstensi) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Gambar crop dan Grad-CAM ikut disimpan supaya detail riwayat bisa dibuka tanpa server
    final isiCrop = await ApiService.unduhFile(hasil.cropUrl);
    final isiGradcam = await ApiService.unduhFile(hasil.gradcamUrl);

    final RiwayatItem item;
    if (riwayatHanyaDiMemori) {
      item = RiwayatItem(
        id: id,
        waktu: DateTime.now(),
        hasil: hasil,
        isiGambar: gambar,
        isiCrop: isiCrop,
        isiGradcam: isiGradcam,
      );
    } else {
      item = RiwayatItem(
        id: id,
        waktu: DateTime.now(),
        hasil: hasil,
        pathGambar: await RiwayatService.simpanFile(gambar, '${id}_asli.$ekstensi'),
        pathCrop: isiCrop == null
            ? null
            : await RiwayatService.simpanFile(isiCrop, '${id}_crop.jpg'),
        pathGradcam: isiGradcam == null
            ? null
            : await RiwayatService.simpanFile(isiGradcam, '${id}_gradcam.jpg'),
      );
    }

    daftar.insert(0, item);
    await _simpan();
    notifyListeners();
  }

  Future<void> hapus(RiwayatItem item) async {
    await _hapusFile(item);
    daftar.removeWhere((e) => e.id == item.id);
    await _simpan();
    notifyListeners();
  }

  Future<void> hapusSemua() async {
    for (final item in daftar) {
      await _hapusFile(item);
    }
    daftar = [];
    await _simpan();
    notifyListeners();
  }

  Future<void> _simpan() async {
    if (riwayatHanyaDiMemori) return;
    await RiwayatService.simpan(daftar);
  }

  Future<void> _hapusFile(RiwayatItem item) async {
    if (riwayatHanyaDiMemori) return;
    await RiwayatService.hapusFile(item.pathGambar);
    await RiwayatService.hapusFile(item.pathCrop);
    await RiwayatService.hapusFile(item.pathGradcam);
  }
}
