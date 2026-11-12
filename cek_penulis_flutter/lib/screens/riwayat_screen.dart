import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/riwayat_item.dart';
import '../providers/riwayat_provider.dart';
import '../utils/format.dart';
import '../utils/gambar_riwayat.dart';
import '../utils/warna.dart';
import '../widgets/dialog_hapus.dart';
import '../widgets/kotak.dart';
import 'detail_riwayat_screen.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final riwayat = context.watch<RiwayatProvider>();
    final daftar = riwayat.daftar;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          if (daftar.isNotEmpty)
            IconButton(
              tooltip: 'Hapus semua',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () async {
                final yakin = await konfirmasiHapus(context, 'Semua riwayat identifikasi akan dihapus.');
                if (yakin) await riwayat.hapusSemua();
              },
            ),
        ],
      ),
      body: daftar.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 48, color: Warna.teksSekunder),
                    SizedBox(height: 12),
                    Text('Belum ada riwayat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    SizedBox(height: 4),
                    Text(
                      riwayatHanyaDiMemori
                          ? 'Hasil identifikasi akan tampil di sini. Di versi web, riwayat hilang saat halaman dimuat ulang.'
                          : 'Hasil identifikasi akan tersimpan di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Warna.teksSekunder),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: daftar.length,
              separatorBuilder: (context, i) => const SizedBox(height: 10),
              itemBuilder: (context, i) => ItemRiwayat(item: daftar[i]),
            ),
    );
  }
}

class ItemRiwayat extends StatelessWidget {
  final RiwayatItem item;

  const ItemRiwayat({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final hasil = item.hasil;
    final judul = hasil.dikenali ? hasil.penulis ?? '-' : 'Tidak Dikenali';
    final gambar = gambarRiwayat(item.isiGambar, item.pathGambar);
    const ikonRusak = Icon(Icons.broken_image_outlined, color: Colors.black38);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailRiwayatScreen(item: item)),
      ),
      child: Kotak(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 64,
                height: 64,
                color: Colors.white,
                child: gambar == null
                    ? ikonRusak
                    : Image(
                        image: ResizeImage(gambar, width: 200),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => ikonRusak,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasil.dikenali ? Warna.teksUtama : Warna.peringatan,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Keyakinan ${formatPersen(hasil.confidence)}',
                    style: const TextStyle(color: Warna.teksSekunder, fontSize: 13),
                  ),
                  Text(
                    formatTanggal(item.waktu),
                    style: const TextStyle(color: Warna.teksSekunder, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Hapus',
              icon: const Icon(Icons.delete_outline, color: Warna.teksSekunder),
              onPressed: () async {
                final riwayat = context.read<RiwayatProvider>();
                final yakin = await konfirmasiHapus(context, 'Riwayat ini akan dihapus.');
                if (yakin) await riwayat.hapus(item);
              },
            ),
          ],
        ),
      ),
    );
  }
}
