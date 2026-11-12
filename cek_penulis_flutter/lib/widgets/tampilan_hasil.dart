import 'package:flutter/material.dart';

import '../models/hasil_identifikasi.dart';
import '../utils/format.dart';
import '../utils/warna.dart';
import 'kotak.dart';

class TampilanHasil extends StatelessWidget {
  final HasilIdentifikasi hasil;
  final ImageProvider? gambarCrop;
  final ImageProvider? gambarGradcam;

  const TampilanHasil({
    super.key,
    required this.hasil,
    required this.gambarCrop,
    required this.gambarGradcam,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KartuPenulis(hasil: hasil),
        const SizedBox(height: 16),
        const Label('Hasil crop'),
        KotakGambar(gambar: gambarCrop),
        const SizedBox(height: 16),
        KartuTopPrediksi(hasil: hasil),
        const SizedBox(height: 16),
        KartuGradcam(gambarCrop: gambarCrop, gambarGradcam: gambarGradcam),
        const SizedBox(height: 16),
        KartuInfoPrediksi(hasil: hasil),
      ],
    );
  }
}

class KartuPenulis extends StatelessWidget {
  final HasilIdentifikasi hasil;

  const KartuPenulis({super.key, required this.hasil});

  @override
  Widget build(BuildContext context) {
    final dikenali = hasil.dikenali;
    final warna = dikenali ? Warna.primary : Warna.peringatan;
    final keterangan = dikenali
        ? 'Keyakinan ${formatPersen(hasil.confidence)}'
        : 'Keyakinan tertinggi ${formatPersen(hasil.confidence)}, di bawah ambang ${formatPersen(hasil.ambang)}';

    return Kotak(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: warna.withAlpha(40), shape: BoxShape.circle),
            child: Icon(dikenali ? Icons.how_to_reg_outlined : Icons.help_outline, color: warna),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dikenali ? 'Penulis teridentifikasi' : 'Penulis belum bisa dipastikan',
                  style: const TextStyle(color: Warna.teksSekunder, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  dikenali ? hasil.penulis ?? '-' : 'Tidak Dikenali',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(keterangan, style: const TextStyle(color: Warna.teksSekunder, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  final bool dikenali;

  const StatusChip({super.key, required this.dikenali});

  @override
  Widget build(BuildContext context) {
    final warna = dikenali ? Warna.primary : Warna.peringatan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: warna.withAlpha(40), borderRadius: BorderRadius.circular(8)),
      child: Text(
        dikenali ? 'Dikenali' : 'Tidak Dikenali',
        style: TextStyle(color: warna, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class KartuTopPrediksi extends StatelessWidget {
  final HasilIdentifikasi hasil;

  const KartuTopPrediksi({super.key, required this.hasil});

  @override
  Widget build(BuildContext context) {
    return Kotak(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Tiga teratas', style: TextStyle(color: Warna.teksSekunder, fontSize: 14)),
              ),
              StatusChip(dikenali: hasil.dikenali),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < hasil.topPrediksi.length; i++)
            BarisPrediksi(prediksi: hasil.topPrediksi[i], utama: i == 0 && hasil.dikenali),
          if (!hasil.dikenali)
            const Text(
              'Daftar ini hanya kemiripan terdekat, bukan identitas yang pasti.',
              style: TextStyle(color: Warna.teksSekunder, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

class BarisPrediksi extends StatelessWidget {
  final Prediksi prediksi;
  final bool utama;

  const BarisPrediksi({super.key, required this.prediksi, required this.utama});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prediksi.idPenulis,
                  style: TextStyle(fontWeight: utama ? FontWeight.w600 : FontWeight.normal),
                ),
              ),
              Text(formatPersen(prediksi.confidence)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prediksi.confidence.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Warna.border,
              color: utama ? Warna.primary : Warna.teksSekunder,
            ),
          ),
        ],
      ),
    );
  }
}

class KartuGradcam extends StatefulWidget {
  final ImageProvider? gambarCrop;
  final ImageProvider? gambarGradcam;

  const KartuGradcam({super.key, required this.gambarCrop, required this.gambarGradcam});

  @override
  State<KartuGradcam> createState() => _KartuGradcamState();
}

class _KartuGradcamState extends State<KartuGradcam> {
  bool tampilkanGradcam = true;

  @override
  Widget build(BuildContext context) {
    return Kotak(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grad-CAM: area yang diperhatikan model',
            style: TextStyle(color: Warna.teksSekunder, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Grad-CAM')),
              ButtonSegment(value: false, label: Text('Gambar asli')),
            ],
            selected: {tampilkanGradcam},
            showSelectedIcon: false,
            onSelectionChanged: (pilihan) => setState(() => tampilkanGradcam = pilihan.first),
          ),
          const SizedBox(height: 12),
          KotakGambar(gambar: tampilkanGradcam ? widget.gambarGradcam : widget.gambarCrop),
          const SizedBox(height: 10),
          const Text(
            'Warna merah dan kuning menandai bagian tulisan yang paling memengaruhi keputusan model. '
            'Warna biru berarti pengaruhnya kecil.',
            style: TextStyle(color: Warna.teksSekunder, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class KartuInfoPrediksi extends StatelessWidget {
  final HasilIdentifikasi hasil;

  const KartuInfoPrediksi({super.key, required this.hasil});

  @override
  Widget build(BuildContext context) {
    return Kotak(
      child: Column(
        children: [
          BarisInfo(ikon: Icons.timer_outlined, label: 'Waktu prediksi', nilai: formatDetik(hasil.waktuProses)),
          BarisInfo(ikon: Icons.memory_outlined, label: 'Algoritma', nilai: hasil.namaModel),
          const BarisInfo(ikon: Icons.check_circle_outline, label: 'Status proses', nilai: 'Berhasil'),
        ],
      ),
    );
  }
}

class BarisInfo extends StatelessWidget {
  final IconData ikon;
  final String label;
  final String nilai;

  const BarisInfo({super.key, required this.ikon, required this.label, required this.nilai});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(ikon, size: 18, color: Warna.teksSekunder),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: const TextStyle(color: Warna.teksSekunder))),
          Flexible(child: Text(nilai, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
