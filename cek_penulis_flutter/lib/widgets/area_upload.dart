import 'package:flutter/material.dart';

import '../utils/warna.dart';

class AreaUpload extends StatelessWidget {
  final VoidCallback onGaleri;
  final VoidCallback onKamera;

  const AreaUpload({super.key, required this.onGaleri, required this.onKamera});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GarisPutusPutus(),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.upload_outlined, color: Warna.teksSekunder, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pilih foto tulisan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(height: 2),
                      Text(
                        'JPG, JPEG, atau PNG. Tulisan lurus dan terang',
                        style: TextStyle(color: Warna.teksSekunder, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onGaleri,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onKamera,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Kamera'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GarisPutusPutus extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Warna.garisUpload
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)));

    for (final metric in path.computeMetrics()) {
      double posisi = 0;
      while (posisi < metric.length) {
        canvas.drawPath(metric.extractPath(posisi, posisi + 6), paint);
        posisi += 11;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
