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

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _http.get(
        _uri(path),
        headers: {'Content-Type': 'application/json', ...?headers},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        throw ApiException('Expected JSON object, got ${decoded.runtimeType}');
      }

      String msg = 'Request failed';
      try {
        final errJson = jsonDecode(res.body);
        if (errJson is Map && errJson['message'] != null) {
          msg = errJson['message'].toString();
        } else if (errJson is String) {
          msg = errJson;
        }
      } catch (_) {
        msg = res.body.isNotEmpty ? res.body : 'Status ${res.statusCode}';
      }
      throw ApiException(msg, statusCode: res.statusCode);
    } on SocketException {
      throw const ApiException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getJsonList(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _http.get(
        _uri(path),
        headers: {'Content-Type': 'application/json', ...?headers},
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is List) {
          return decoded.map((e) => e as Map<String, dynamic>).toList();
        }
        throw ApiException('Expected JSON array, got ${decoded.runtimeType}');
      }

      String msg = 'Request failed';
      try {
        final errJson = jsonDecode(res.body);
        if (errJson is Map && errJson['message'] != null) {
          msg = errJson['message'].toString();
        } else if (errJson is String) {
          msg = errJson;
        }
      } catch (_) {
        msg = res.body.isNotEmpty ? res.body : 'Status ${res.statusCode}';
      }
      throw ApiException(msg, statusCode: res.statusCode);
    } on SocketException {
      throw const ApiException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    try {
      final res = await _http.put(
        _uri(path),
        headers: {'Content-Type': 'application/json', ...?headers},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        throw ApiException('Expected JSON object');
      }

      String msg = 'Request failed';
      try {
        final errJson = jsonDecode(res.body);
        if (errJson is Map && errJson['message'] != null) {
          msg = errJson['message'].toString();
        } else if (errJson is String) {
          msg = errJson;
        }
      } catch (_) {
        msg = res.body.isNotEmpty ? res.body : 'Status ${res.statusCode}';
      }
      throw ApiException(msg, statusCode: res.statusCode);
    } on SocketException {
      throw const ApiException('No internet connection');
    } on FormatException {
      throw const ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  Future<void> delete(String path, {Map<String, String>? headers}) async {
    try {
      final res = await _http.delete(
        _uri(path),
        headers: {'Content-Type': 'application/json', ...?headers},
      );

      if (res.statusCode == 204 || res.statusCode == 200) {
        return;
      }

      String msg = 'Request failed';
      try {
        final errJson = jsonDecode(res.body);
        if (errJson is Map && errJson['message'] != null) {
          msg = errJson['message'].toString();
        } else if (errJson is String) {
          msg = errJson;
        }
      } catch (_) {
        msg = res.body.isNotEmpty ? res.body : 'Status ${res.statusCode}';
      }
      throw ApiException(msg, statusCode: res.statusCode);
    } on SocketException {
      throw const ApiException('No internet connection');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  void close() => _http.close();
}
