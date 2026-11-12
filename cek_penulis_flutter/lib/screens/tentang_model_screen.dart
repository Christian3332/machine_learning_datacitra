import 'package:flutter/material.dart';

import '../models/info_model.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../utils/warna.dart';
import '../widgets/dialog_server.dart';
import '../widgets/kotak.dart';

class TentangModelScreen extends StatefulWidget {
  const TentangModelScreen({super.key});

  @override
  State<TentangModelScreen> createState() => _TentangModelScreenState();
}

class _TentangModelScreenState extends State<TentangModelScreen> {
  InfoModel? info;
  String? pesanError;
  bool sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  Future<void> muatInfo() async {
    setState(() {
      sedangMemuat = true;
      pesanError = null;
    });
    await ambilData();
  }

  Future<void> ambilData() async {
    try {
      final data = await ApiService.ambilInfoModel();
      if (!mounted) return;
      setState(() {
        info = data;
        pesanError = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => pesanError = e.pesan);
    } finally {
      if (mounted) setState(() => sedangMemuat = false);
    }
  }

  String nilaiMetrik(String kunci) {
    final nilai = info?.metrics?[kunci];
    return nilai == null ? 'Belum tersedia' : formatPersen(nilai);
  }

  String nilaiDataset(String kunci) {
    final nilai = info?.dataset?[kunci];
    return nilai == null ? 'Belum tersedia' : '$nilai citra';
  }

  @override
  Widget build(BuildContext context) {
    final modelAktif = info?.modelTersedia ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Tentang Model', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: sedangMemuat ? null : muatInfo,
          ),
          IconButton(
            tooltip: 'Alamat server',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await tampilkanDialogServer(context);
              if (mounted) muatInfo();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: muatInfo,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Kotak(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('EfficientNetV2B0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                      ),
                      if (info != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: (modelAktif ? Warna.primary : Warna.peringatan).withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            modelAktif ? 'Model aktif' : 'Belum dilatih',
                            style: TextStyle(
                              color: modelAktif ? Warna.primary : Warna.peringatan,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'EfficientNetV2B0 adalah arsitektur CNN dari keluarga EfficientNetV2 (Tan dan Le, 2021). '
                    'Model ini dirancang supaya akurat tapi tetap ringan, dengan sekitar 7 juta parameter. '
                    'Di aplikasi ini, model dilatih ulang dari bobot ImageNet (transfer learning) '
                    'menggunakan dataset tulisan tangan.',
                    style: TextStyle(color: Warna.teksSekunder, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Kotak(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fungsi dalam aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    'Model menerima potongan tulisan, mengenali ciri goresan seperti kemiringan, tebal tipis garis, '
                    'dan jarak antar huruf, lalu menghitung peluang untuk setiap penulis yang dikenal. '
                    'Jika peluang tertinggi di bawah ambang, hasil ditandai "Tidak Dikenali".',
                    style: TextStyle(color: Warna.teksSekunder, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (sedangMemuat && info == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (pesanError != null) ...[
              Kotak(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data model belum bisa diambil', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(pesanError!, style: const TextStyle(color: Warna.teksSekunder)),
                    const SizedBox(height: 10),
                    OutlinedButton(onPressed: muatInfo, child: const Text('Coba lagi')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Kotak(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Dataset', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const BarisData(label: 'Sumber', nilai: 'Tulisan tangan mahasiswa'),
                  BarisData(
                    label: 'Jumlah kelas penulis',
                    nilai: info?.jumlahKelas == null ? 'Belum tersedia' : '${info!.jumlahKelas} penulis',
                  ),
                  BarisData(label: 'Data train', nilai: nilaiDataset('train')),
                  BarisData(label: 'Data validation', nilai: nilaiDataset('validation')),
                  BarisData(label: 'Data test', nilai: nilaiDataset('test')),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Label('Hasil evaluasi pada data test'),
            Row(
              children: [
                Expanded(child: KotakMetrik(label: 'Accuracy', nilai: nilaiMetrik('accuracy'))),
                const SizedBox(width: 12),
                Expanded(child: KotakMetrik(label: 'Precision', nilai: nilaiMetrik('precision'))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: KotakMetrik(label: 'Recall', nilai: nilaiMetrik('recall'))),
                const SizedBox(width: 12),
                Expanded(child: KotakMetrik(label: 'F1-Score', nilai: nilaiMetrik('f1_score'))),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Precision, recall, dan F1-score memakai rata-rata macro. '
              'Ambang pengenalan: ${info == null ? 'Belum tersedia' : formatPersen(info!.ambang)}.',
              style: const TextStyle(color: Warna.teksSekunder, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Kotak(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tentang Grad-CAM', style: TextStyle(fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text(
                    'Grad-CAM (Gradient-weighted Class Activation Mapping) melihat lapisan konvolusi terakhir '
                    'EfficientNetV2B0 dan menghitung bagian gambar yang paling berpengaruh terhadap tebakan. '
                    'Hasilnya ditampilkan sebagai heatmap di atas tulisan, sehingga keputusan model bisa diperiksa.',
                    style: TextStyle(color: Warna.teksSekunder, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BarisData extends StatelessWidget {
  final String label;
  final String nilai;

  const BarisData({super.key, required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Warna.teksSekunder))),
          Text(nilai),
        ],
      ),
    );
  }
}

class KotakMetrik extends StatelessWidget {
  final String label;
  final String nilai;

  const KotakMetrik({super.key, required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    final belumAda = nilai == 'Belum tersedia';
    return Kotak(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Warna.teksSekunder, fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            nilai,
            style: TextStyle(
              fontSize: belumAda ? 14 : 22,
              fontWeight: FontWeight.w600,
              color: belumAda ? Warna.teksSekunder : Warna.teksUtama,
            ),
          ),
        ],
      ),
    );
  }
}
