import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/warna.dart';
import 'kotak.dart';

class PratinjauGambar extends StatelessWidget {
  final Uint8List gambar;
  final bool nonaktif;
  final VoidCallback onGaleri;
  final VoidCallback onKamera;
  final VoidCallback onHapus;

  const PratinjauGambar({
    super.key,
    required this.gambar,
    required this.nonaktif,
    required this.onGaleri,
    required this.onKamera,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Kotak(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Label('Pratinjau gambar'),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 240),
              color: Colors.white,
              child: Image.memory(gambar, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: nonaktif ? null : onGaleri,
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Ganti'),
              ),
              TextButton.icon(
                onPressed: nonaktif ? null : onKamera,
                icon: const Icon(Icons.photo_camera_outlined, size: 18),
                label: const Text('Foto ulang'),
              ),
              TextButton.icon(
                onPressed: nonaktif ? null : onHapus,
                style: TextButton.styleFrom(foregroundColor: Warna.bahaya),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
