import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/pengaturan_service.dart';
import '../utils/pesan.dart';
import '../utils/warna.dart';

Future<void> tampilkanDialogServer(BuildContext context) async {
  final alamat = await showDialog<String>(
    context: context,
    builder: (_) => const DialogServer(),
  );
  if (alamat == null || alamat.trim().isEmpty) return;

  await PengaturanService.simpan(alamat);
  final terhubung = await ApiService.cekKoneksi();
  if (!context.mounted) return;
  tampilkanPesan(
    context,
    terhubung ? 'Server terhubung' : 'Alamat disimpan, tapi server belum bisa dihubungi',
    error: !terhubung,
  );
}

class DialogServer extends StatefulWidget {
  const DialogServer({super.key});

  @override
  State<DialogServer> createState() => _DialogServerState();
}

class _DialogServerState extends State<DialogServer> {
  final controller = TextEditingController(text: PengaturanService.alamatServer);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Warna.card,
      title: const Text('Alamat server'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              hintText: 'http://192.168.1.5:8000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Web (Chrome) di laptop yang sama: http://localhost:8000\n'
            'Emulator Android: http://10.0.2.2:8000\n'
            'HP asli: pakai IP laptop di Wi-Fi yang sama, contoh http://192.168.1.5:8000',
            style: TextStyle(color: Warna.teksSekunder, fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Simpan')),
      ],
    );
  }
}
