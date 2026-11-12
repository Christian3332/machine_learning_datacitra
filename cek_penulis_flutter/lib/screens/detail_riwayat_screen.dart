import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/riwayat_item.dart';
import '../providers/riwayat_provider.dart';
import '../utils/format.dart';
import '../utils/gambar_riwayat.dart';
import '../utils/warna.dart';
import '../widgets/dialog_hapus.dart';
import '../widgets/kotak.dart';
import '../widgets/tampilan_hasil.dart';

class DetailRiwayatScreen extends StatelessWidget {
  final RiwayatItem item;

  const DetailRiwayatScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Detail riwayat'),
        actions: [
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final riwayat = context.read<RiwayatProvider>();
              final navigator = Navigator.of(context);
              final yakin = await konfirmasiHapus(context, 'Riwayat ini akan dihapus.');
              if (!yakin) return;
              await riwayat.hapus(item);
              navigator.pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            formatTanggal(item.waktu),
            style: const TextStyle(color: Warna.teksSekunder),
          ),
          const SizedBox(height: 12),
          const Label('Gambar yang dikirim'),
          KotakGambar(gambar: gambarRiwayat(item.isiGambar, item.pathGambar)),
          const SizedBox(height: 16),
          TampilanHasil(
            hasil: item.hasil,
            gambarCrop: gambarRiwayat(item.isiCrop, item.pathCrop),
            gambarGradcam: gambarRiwayat(item.isiGradcam, item.pathGradcam),
          ),
        ],
      ),
    );
  }
}
