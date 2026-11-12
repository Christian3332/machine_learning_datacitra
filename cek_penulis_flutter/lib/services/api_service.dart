import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/hasil_identifikasi.dart';
import '../models/info_model.dart';
import 'pengaturan_service.dart';

class ApiException implements Exception {
  final String pesan;
  ApiException(this.pesan);

  @override
  String toString() => pesan;
}

class ApiService {
  static String get _baseUrl => PengaturanService.alamatServer;

  static String urlLengkap(String path) => '$_baseUrl$path';

  static String get _pesanTidakTerhubung =>
      'Tidak bisa terhubung ke server $_baseUrl. Cek alamat server di pengaturan.';

  static Future<HasilIdentifikasi> identifikasi(List<int> gambar, String ekstensi) async {
    final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/identify'));
    request.files.add(http.MultipartFile.fromBytes('file', gambar, filename: 'gambar.$ekstensi'));

    final http.Response response;
    try {
      final streamed = await request.send().timeout(const Duration(seconds: 60));
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespons. Coba lagi.');
    } on SocketException {
      throw ApiException(_pesanTidakTerhubung);
    } on http.ClientException {
      throw ApiException(_pesanTidakTerhubung);
    }

    final data = _bacaJson(response);
    if (response.statusCode != 200 || data['success'] != true) {
      throw ApiException(data['message']?.toString() ?? 'Terjadi kesalahan di server.');
    }
    return HasilIdentifikasi.fromJson(data);
  }

  static Future<InfoModel> ambilInfoModel() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/model-info'))
          .timeout(const Duration(seconds: 15));
      final data = _bacaJson(response);
      if (response.statusCode != 200) {
        throw ApiException(data['message']?.toString() ?? 'Gagal mengambil info model.');
      }
      return InfoModel.fromJson(data);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(_pesanTidakTerhubung);
    }
  }

  static Future<bool> cekKoneksi() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Uint8List?> unduhFile(String path) async {
    if (path.isEmpty) return null;
    try {
      final response = await http
          .get(Uri.parse(urlLengkap(path)))
          .timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) return response.bodyBytes;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _bacaJson(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Respons server tidak valid (kode ${response.statusCode}).');
    }
  }
}
