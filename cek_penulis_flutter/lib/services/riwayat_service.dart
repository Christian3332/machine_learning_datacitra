import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/riwayat_item.dart';

class RiwayatService {
  static const _kunci = 'riwayat_identifikasi';

  static Future<List<RiwayatItem>> muat() async {
    final prefs = await SharedPreferences.getInstance();
    final teks = prefs.getString(_kunci);
    if (teks == null) return [];

    try {
      final daftar = jsonDecode(teks) as List;
      return daftar.map((e) => RiwayatItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> simpan(List<RiwayatItem> daftar) async {
    final prefs = await SharedPreferences.getInstance();
    final teks = jsonEncode(daftar.map((e) => e.toJson()).toList());
    await prefs.setString(_kunci, teks);
  }

  static Future<String> simpanFile(List<int> isi, String namaFile) async {
    final folderApp = await getApplicationDocumentsDirectory();
    final folder = Directory('${folderApp.path}/riwayat');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final file = File('${folder.path}/$namaFile');
    await file.writeAsBytes(isi);
    return file.path;
  }

  static Future<void> hapusFile(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
