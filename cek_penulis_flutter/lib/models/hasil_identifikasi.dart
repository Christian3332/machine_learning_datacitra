class Prediksi {
  final String idPenulis;
  final double confidence;

  Prediksi({required this.idPenulis, required this.confidence});

  factory Prediksi.fromJson(Map<String, dynamic> json) {
    return Prediksi(
      idPenulis: json['writer_id'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'writer_id': idPenulis,
        'confidence': confidence,
      };
}

class HasilIdentifikasi {
  final String status;
  final String? penulis;
  final double confidence;
  final List<Prediksi> topPrediksi;
  final double ambang;
  final String gradcamUrl;
  final String cropUrl;
  final double waktuProses;
  final String namaModel;

  HasilIdentifikasi({
    required this.status,
    required this.penulis,
    required this.confidence,
    required this.topPrediksi,
    required this.ambang,
    required this.gradcamUrl,
    required this.cropUrl,
    required this.waktuProses,
    required this.namaModel,
  });

  bool get dikenali => status == 'recognized';

  factory HasilIdentifikasi.fromJson(Map<String, dynamic> json) {
    final daftar = (json['top_predictions'] as List? ?? [])
        .map((e) => Prediksi.fromJson(e as Map<String, dynamic>))
        .toList();

    return HasilIdentifikasi(
      status: json['status'] as String? ?? 'not_recognized',
      penulis: json['predicted_writer'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      topPrediksi: daftar,
      ambang: (json['threshold'] as num?)?.toDouble() ?? 0.5,
      gradcamUrl: json['gradcam_url'] as String? ?? '',
      cropUrl: json['crop_url'] as String? ?? '',
      waktuProses: (json['processing_time'] as num?)?.toDouble() ?? 0.0,
      namaModel: json['model_name'] as String? ?? 'EfficientNetV2B0',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'predicted_writer': penulis,
        'confidence': confidence,
        'top_predictions': topPrediksi.map((p) => p.toJson()).toList(),
        'threshold': ambang,
        'gradcam_url': gradcamUrl,
        'crop_url': cropUrl,
        'processing_time': waktuProses,
        'model_name': namaModel,
      };
}
