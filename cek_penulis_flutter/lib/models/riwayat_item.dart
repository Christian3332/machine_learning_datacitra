import 'dart:typed_data';

import 'hasil_identifikasi.dart';

class RiwayatItem {
  final String id;
  final DateTime waktu;
  final HasilIdentifikasi hasil;

  // Android/iOS: gambar disimpan sebagai file di folder dokumen aplikasi
  final String? pathGambar;
  final String? pathCrop;
  final String? pathGradcam;

  // Web: gambar hanya disimpan di memori, tidak ikut disimpan ke JSON
  final Uint8List? isiGambar;
  final Uint8List? isiCrop;
  final Uint8List? isiGradcam;

  RiwayatItem({
    required this.id,
    required this.waktu,
    required this.hasil,
    this.pathGambar,
    this.pathCrop,
    this.pathGradcam,
    this.isiGambar,
    this.isiCrop,
    this.isiGradcam,
  });

  factory RiwayatItem.fromJson(Map<String, dynamic> json) {
    return RiwayatItem(
      id: json['id'] as String,
      waktu: DateTime.parse(json['waktu'] as String),
      pathGambar: json['path_gambar'] as String?,
      pathCrop: json['path_crop'] as String?,
      pathGradcam: json['path_gradcam'] as String?,
      hasil: HasilIdentifikasi.fromJson(json['hasil'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'waktu': waktu.toIso8601String(),
        'path_gambar': pathGambar,
        'path_crop': pathCrop,
        'path_gradcam': pathGradcam,
        'hasil': hasil.toJson(),
      };
}
