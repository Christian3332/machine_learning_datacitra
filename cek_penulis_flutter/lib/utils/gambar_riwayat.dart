import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Gambar riwayat diambil dari memori (web) atau dari file di HP (Android/iOS).
ImageProvider? gambarRiwayat(Uint8List? isi, String? path) {
  if (isi != null) return MemoryImage(isi);
  if (kIsWeb || path == null) return null;
  final file = File(path);
  return file.existsSync() ? FileImage(file) : null;
}
