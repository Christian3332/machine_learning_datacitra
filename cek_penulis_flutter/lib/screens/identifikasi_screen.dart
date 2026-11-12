import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/identifikasi_provider.dart';
import '../providers/riwayat_provider.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../utils/pesan.dart';
import '../utils/warna.dart';
import '../widgets/area_upload.dart';
import '../widgets/dialog_server.dart';
import '../widgets/kartu_ocr.dart';
import '../widgets/pratinjau_gambar.dart';
import '../widgets/tampilan_hasil.dart';
import 'kamera_screen.dart';

class IdentifikasiScreen extends StatelessWidget {
  const IdentifikasiScreen({super.key});

  Future<void> pilihDariGaleri(BuildContext context) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2500,
      imageQuality: 92,
    );
    if (file == null || !context.mounted) return;
    await pakaiGambar(context, file);
  }

  Future<void> ambilDariKamera(BuildContext context) async {
    final foto = await Navigator.push<XFile>(
      context,
      MaterialPageRoute(builder: (_) => const KameraScreen()),
    );
    if (foto == null || !context.mounted) return;
    await pakaiGambar(context, foto);
  }

  Future<void> pakaiGambar(BuildContext context, XFile file) async {
    final Uint8List isi;
    try {
      isi = await file.readAsBytes();
    } catch (_) {
      if (context.mounted) tampilkanPesan(context, 'Gambar tidak bisa dibaca.', error: true);
      return;
    }
    if (!context.mounted) return;

    final ekstensi = jenisGambar(isi);
    if (ekstensi == null) {
      tampilkanPesan(context, 'Format tidak didukung. Gunakan JPG, JPEG, atau PNG.', error: true);
      return;
    }
    context.read<IdentifikasiProvider>().setGambar(isi, ekstensi);
  }

  Future<void> jalankanIdentifikasi(BuildContext context) async {
    final provider = context.read<IdentifikasiProvider>();
    final riwayat = context.read<RiwayatProvider>();

    final berhasil = await provider.identifikasi();
    if (!context.mounted) return;

    if (berhasil) {
      tampilkanPesan(context, 'Identifikasi selesai');
      try {
        await riwayat.tambah(provider.hasil!, provider.gambar!, provider.ekstensiGambar);
      } catch (_) {
        if (context.mounted) {
          tampilkanPesan(context, 'Hasil tampil, tapi gagal disimpan ke riwayat', error: true);
        }
      }
    } else {
      tampilkanPesan(context, provider.pesanError ?? 'Identifikasi gagal', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IdentifikasiProvider>();
    final hasil = provider.hasil;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Warna.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Cek Penulis', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            tooltip: 'Alamat server',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => tampilkanDialogServer(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (provider.gambar == null)
            AreaUpload(
              onGaleri: () => pilihDariGaleri(context),
              onKamera: () => ambilDariKamera(context),
            )
          else
            PratinjauGambar(
              gambar: provider.gambar!,
              nonaktif: provider.sedangProses,
              onGaleri: () => pilihDariGaleri(context),
              onKamera: () => ambilDariKamera(context),
              onHapus: provider.hapusGambar,
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: provider.gambar == null || provider.sedangProses
                ? null
                : () => jalankanIdentifikasi(context),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            icon: provider.sedangProses
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.person_search_outlined),
            label: Text(provider.sedangProses ? 'Memproses...' : 'Identifikasi Penulis'),
          ),
          if (provider.pesanError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Warna.bahaya.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Warna.bahaya.withAlpha(90)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Warna.bahaya),
                  const SizedBox(width: 10),
                  Expanded(child: Text(provider.pesanError!)),
                ],
              ),
            ),
          ],
          if (hasil != null) ...[
            const SizedBox(height: 20),
            TampilanHasil(
              hasil: hasil,
              gambarCrop: NetworkImage(ApiService.urlLengkap(hasil.cropUrl)),
              gambarGradcam: NetworkImage(ApiService.urlLengkap(hasil.gradcamUrl)),
            ),
          ],
          const SizedBox(height: 16),
          const KartuOcr(),
        ],
      ),
    );
  }
}
