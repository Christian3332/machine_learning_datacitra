import 'package:flutter/material.dart';

import '../utils/warna.dart';

Future<bool> konfirmasiHapus(BuildContext context, String pesan) async {
  final jawaban = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: Warna.card,
      title: const Text('Hapus riwayat'),
      content: Text(pesan),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Warna.bahaya),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return jawaban ?? false;
}
