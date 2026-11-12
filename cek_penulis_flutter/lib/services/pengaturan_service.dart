import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PengaturanService {
  static const _kunciServer = 'alamat_server';

  // Web jalan di browser laptop, jadi backend cukup diakses lewat localhost.
  // 10.0.2.2 adalah alamat laptop jika aplikasi dijalankan di emulator Android.
  static String alamatServer = kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';

  static Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();
    final tersimpan = prefs.getString(_kunciServer);
    if (tersimpan != null) alamatServer = _rapikan(tersimpan);
  }

  static Future<void> simpan(String alamat) async {
    alamatServer = _rapikan(alamat);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kunciServer, alamatServer);
  }

  static String _rapikan(String alamat) {
    var bersih = alamat.trim();
    if (!bersih.startsWith('http://') && !bersih.startsWith('https://')) {
      bersih = 'http://$bersih';
    }
    while (bersih.endsWith('/')) {
      bersih = bersih.substring(0, bersih.length - 1);
    }

    // Di browser, 0.0.0.0 (alamat "dengar di semua jaringan" milik uvicorn) dan
    // 10.0.2.2 (khusus emulator Android) tidak bisa dihubungi. Backend ada di laptop yang sama.
    final uri = Uri.tryParse(bersih);
    if (kIsWeb && uri != null && (uri.host == '0.0.0.0' || uri.host == '10.0.2.2')) {
      bersih = uri.replace(host: 'localhost').toString();
    }
    return bersih;
  }
}
