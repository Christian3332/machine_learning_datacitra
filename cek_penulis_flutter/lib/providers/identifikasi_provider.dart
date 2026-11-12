import 'package:flutter/foundation.dart';

import '../models/hasil_identifikasi.dart';
import '../services/api_service.dart';

class IdentifikasiProvider extends ChangeNotifier {
  Uint8List? gambar;
  String ekstensiGambar = 'jpg';
  HasilIdentifikasi? hasil;
  bool sedangProses = false;
  String? pesanError;

  void setGambar(Uint8List isi, String ekstensi) {
    gambar = isi;
    ekstensiGambar = ekstensi;
    hasil = null;
    pesanError = null;
    notifyListeners();
  }

  void hapusGambar() {
    gambar = null;
    hasil = null;
    pesanError = null;
    notifyListeners();
  }

  Future<bool> identifikasi() async {
    if (gambar == null || sedangProses) return false;

    sedangProses = true;
    hasil = null;
    pesanError = null;
    notifyListeners();

    try {
      hasil = await ApiService.identifikasi(gambar!, ekstensiGambar);
      return true;
    } on ApiException catch (e) {
      pesanError = e.pesan;
      return false;
    } catch (e) {
      pesanError = 'Terjadi kesalahan: $e';
      return false;
    } finally {
      sedangProses = false;
      notifyListeners();
    }
  }
}
