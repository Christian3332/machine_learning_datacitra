class InfoModel {
  final String namaModel;
  final bool modelTersedia;
  final int? jumlahKelas;
  final double ambang;
  final Map<String, int>? dataset;
  final Map<String, double>? metrics;

  InfoModel({
    required this.namaModel,
    required this.modelTersedia,
    required this.jumlahKelas,
    required this.ambang,
    required this.dataset,
    required this.metrics,
  });

  factory InfoModel.fromJson(Map<String, dynamic> json) {
    Map<String, int>? dataset;
    if (json['dataset'] is Map) {
      dataset = (json['dataset'] as Map).map<String, int>(
        (k, v) => MapEntry(k.toString(), (v as num).toInt()),
      );
    }

    Map<String, double>? metrics;
    if (json['metrics'] is Map) {
      metrics = (json['metrics'] as Map).map<String, double>(
        (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
      );
    }

    return InfoModel(
      namaModel: json['model_name'] as String? ?? 'EfficientNetV2B0',
      modelTersedia: json['model_available'] == true,
      jumlahKelas: (json['num_classes'] as num?)?.toInt(),
      ambang: (json['threshold'] as num?)?.toDouble() ?? 0.5,
      dataset: dataset,
      metrics: metrics,
    );
  }
}
