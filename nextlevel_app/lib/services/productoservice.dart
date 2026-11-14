import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/producto.dart';

class ProductoService {
  static final Map<String, Uint8List> _cacheImagenes = {};

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://studious-palm-tree-x5xgvjrxq56pc9rg-8081.app.github.dev/api/productos',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  Future<Options> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token')?.trim() ?? '';
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
  }

  Future<Uint8List?> obtenerBytesImagen(String url) async {
    if (_cacheImagenes.containsKey(url)) {
      return _cacheImagenes[url];
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token')?.trim() ?? '';
      final response = await _dio.getUri<List<int>>(
        Uri.parse(url),
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': 'image/*,*/*',
            if (token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data!.isNotEmpty) {
        final bytes = Uint8List.fromList(response.data!);
        _cacheImagenes[url] = bytes;
        return bytes;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<String?> subirImagenBytes(
    Uint8List bytes,
    String nombreArchivo,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token')?.trim() ?? '';

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: nombreArchivo),
      });

      final response = await _dio.post(
        '/subir-imagen',
        data: formData,
        options: Options(
          headers: {if (token.isNotEmpty) 'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data);
        return data['ruta']?.toString();
      }
      return null;
    } catch (e) {
      debugPrint('Error subiendo imagen: $e');
      return null;
    }
  }

  Future<List<Producto>> obtenerProductos({int page = 0, int size = 6}) async {
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.get(
        '',
        queryParameters: {'page': page, 'size': size},
        options: options,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        List<dynamic> listaJson = [];

        if (rawData is List) {
          listaJson = rawData;
        } else if (rawData is Map<String, dynamic>) {
          listaJson =
              rawData['content'] ??
              rawData['productos'] ??
              rawData['data'] ??
              [];
        }

        return listaJson
            .map((json) => Producto.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      debugPrint('Error Dio en obtenerProductos: ${e.response?.statusCode}');
      throw Exception(
        'Error HTTP ${e.response?.statusCode ?? "Red"}: Verifica /api/productos',
      );
    } catch (e) {
      throw Exception('Error procesando datos: $e');
    }
  }

  Future<bool> crearProducto(Producto nuevoProducto) async {
    try {
      final options = await _getAuthHeaders();
      final response = await _dio.post(
        '',
        data: nuevoProducto.toJson(),
        options: options,
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      throw Exception(
        'Error ${e.response?.statusCode ?? ""}: No se pudo crear',
      );
    }
  }
}
