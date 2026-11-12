import 'package:flutter_test/flutter_test.dart';

import 'package:cek_penulis/models/hasil_identifikasi.dart';
import 'package:cek_penulis/utils/format.dart';

void main() {
  test('format persen dan detik', () {
    expect(formatPersen(0.87), '87,0%');
    expect(formatDetik(0.4), '0,40 detik');
  });

  test('cek format gambar', () {
    expect(jenisGambar([0xFF, 0xD8, 0xFF, 0xE0, 0x00]), 'jpg');
    expect(jenisGambar([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]), 'png');
    // HEIC diawali "....ftyp"
    expect(jenisGambar([0x00, 0x00, 0x00, 0x18, 0x66, 0x74, 0x79, 0x70]), null);
    expect(jenisGambar([]), null);
  });

  test('membaca respons backend', () {
    final hasil = HasilIdentifikasi.fromJson({
      'success': true,
      'status': 'recognized',
      'predicted_writer': 'A250014',
      'confidence': 0.87,
      'top_predictions': [
        {'writer_id': 'A250014', 'confidence': 0.87},
        {'writer_id': 'A250029', 'confidence': 0.06},
        {'writer_id': 'A240037', 'confidence': 0.03},
      ],
      'threshold': 0.5,
      'gradcam_url': '/results/gradcam/a.jpg',
      'crop_url': '/results/crop/a.jpg',
      'processing_time': 0.4,
      'model_name': 'EfficientNetV2B0',
    });
    expect(hasil.dikenali, true);
    expect(hasil.topPrediksi.length, 3);
    expect(hasil.topPrediksi.first.idPenulis, 'A250014');
  });
}
