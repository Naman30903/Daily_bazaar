import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final String baseUrl;
  final http.Client _http;

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath');
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _http.post(
        _uri(path),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
          ...?headers,
        },
        body: jsonEncode(body),
      );

      final raw = res.body;
      Map<String, dynamic> decoded;
      try {
        decoded = raw.isEmpty
            ? <String, dynamic>{}
            : (jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        decoded = <String, dynamic>{'message': raw};
      }

      if (res.statusCode < 200 || res.statusCode >= 300) {
        final msg = (decoded['message'] ?? decoded['error'] ?? 'Request failed')
            .toString();
        throw ApiException(msg, statusCode: res.statusCode);
      }

      return decoded;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(kDebugMode ? e.toString() : 'Network error');
    }
  }

  void close() => _http.close();
}
