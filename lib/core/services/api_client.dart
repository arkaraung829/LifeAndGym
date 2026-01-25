import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/supabase_config.dart';
import '../exceptions/exceptions.dart';
import 'logger_service.dart';

/// HTTP client for communicating with the Next.js API backend.
/// Automatically includes JWT from Supabase auth.
class ApiClient {
  final http.Client _httpClient;
  final String _baseUrl;

  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  /// Get current access token from Supabase
  String? get _accessToken => SupabaseConfig.currentSession?.accessToken;

  /// Default headers with auth
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  /// Make a GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint, queryParams);
    final hasAuth = _accessToken != null;
    AppLogger.api('GET $uri (auth: $hasAuth)');

    try {
      final response = await _httpClient.get(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      AppLogger.error('GET request failed', error: e, tag: 'API');
      throw _handleError(e);
    }
  }

  /// Make a POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint);
    final hasAuth = _accessToken != null;
    AppLogger.api('POST $uri (auth: $hasAuth)');

    try {
      final response = await _httpClient.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      AppLogger.error('POST request failed', error: e, tag: 'API');
      throw _handleError(e);
    }
  }

  /// Make a PATCH request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint);
    AppLogger.api('PATCH $uri');

    try {
      final response = await _httpClient.patch(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response, fromJson);
    } catch (e) {
      AppLogger.error('PATCH request failed', error: e, tag: 'API');
      throw _handleError(e);
    }
  }

  /// Make a DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final uri = _buildUri(endpoint);
    AppLogger.api('DELETE $uri');

    try {
      final response = await _httpClient.delete(uri, headers: _headers);
      return _handleResponse(response, fromJson);
    } catch (e) {
      AppLogger.error('DELETE request failed', error: e, tag: 'API');
      throw _handleError(e);
    }
  }

  Uri _buildUri(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    if (queryParams == null || queryParams.isEmpty) return uri;

    return uri.replace(
      queryParameters:
          queryParams.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to parse API response: ${response.body}', tag: 'API');
      throw ApiException(
        'Invalid response from server',
        statusCode: response.statusCode,
        endpoint: response.request?.url.path,
        code: 'PARSE_ERROR',
      );
    }

    final success = json['success'] as bool? ?? false;

    if (!success) {
      final error = json['error'] as Map<String, dynamic>?;
      final errorCode = error?['code'] as String? ?? 'UNKNOWN_ERROR';
      final errorMessage = error?['message'] as String? ?? 'An error occurred';

      AppLogger.error(
        'API Error: $errorCode - $errorMessage (${response.statusCode})',
        tag: 'API',
      );

      throw ApiException(
        errorMessage,
        statusCode: response.statusCode,
        endpoint: response.request?.url.path,
        code: errorCode,
      );
    }

    final data = json['data'];
    final meta = json['meta'] as Map<String, dynamic>?;

    return ApiResponse<T>(
      data: fromJson != null && data is Map<String, dynamic>
          ? fromJson(data)
          : data as T,
      meta: meta != null ? ApiMeta.fromJson(meta) : null,
    );
  }

  AppException _handleError(Object error) {
    if (error is ApiException) return error;

    if (error is http.ClientException) {
      return NetworkException(
        'Network error: ${error.message}',
        originalError: error,
      );
    }

    return NetworkException(
      'Request failed',
      originalError: error,
    );
  }

  void dispose() {
    _httpClient.close();
  }
}

/// API response wrapper
class ApiResponse<T> {
  final T data;
  final ApiMeta? meta;

  const ApiResponse({
    required this.data,
    this.meta,
  });
}

/// API response metadata (for pagination)
class ApiMeta {
  final int? page;
  final int? limit;
  final int? total;
  final bool? hasMore;

  const ApiMeta({
    this.page,
    this.limit,
    this.total,
    this.hasMore,
  });

  factory ApiMeta.fromJson(Map<String, dynamic> json) {
    return ApiMeta(
      page: json['page'] as int?,
      limit: json['limit'] as int?,
      total: json['total'] as int?,
      hasMore: json['hasMore'] as bool?,
    );
  }
}

/// Extension on ApiException for common checks
extension ApiExceptionHelpers on ApiException {
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => code == 'VALIDATION_ERROR';
  bool get isConflict => statusCode == 409;
}
