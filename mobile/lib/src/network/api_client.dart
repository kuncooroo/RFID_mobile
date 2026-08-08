import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_envelope.dart';
import 'api_exception.dart';
import 'connectivity_service.dart';
import 'dio_provider.dart';
import 'network_loading.dart';

/// Thin Dio wrapper: offline check, loading counter, envelope unwrap.
class ApiClient {
  ApiClient({
    required Dio dio,
    required ConnectivityService connectivity,
    required NetworkLoadingNotifier loading,
  }) : _dio = dio,
       _connectivity = connectivity,
       _loading = loading;

  final Dio _dio;
  final ConnectivityService _connectivity;
  final NetworkLoadingNotifier _loading;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic data)? parser,
    bool trackLoading = true,
  }) {
    return _request(
      () => _dio.get<dynamic>(path, queryParameters: query),
      parser: parser,
      trackLoading: trackLoading,
    );
  }

  Future<T> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    Options? options,
    T Function(dynamic data)? parser,
    bool trackLoading = true,
  }) {
    return _request(
      () => _dio.post<dynamic>(
        path,
        data: data,
        queryParameters: query,
        options: options,
      ),
      parser: parser,
      trackLoading: trackLoading,
    );
  }

  Future<T> put<T>(
    String path, {
    Object? data,
    T Function(dynamic data)? parser,
    bool trackLoading = true,
  }) {
    return _request(
      () => _dio.put<dynamic>(path, data: data),
      parser: parser,
      trackLoading: trackLoading,
    );
  }

  Future<T> delete<T>(
    String path, {
    Object? data,
    T Function(dynamic data)? parser,
    bool trackLoading = true,
  }) {
    return _request(
      () => _dio.delete<dynamic>(path, data: data),
      parser: parser,
      trackLoading: trackLoading,
    );
  }

  Future<Response<dynamic>> raw(Future<Response<dynamic>> Function() call) {
    return _guard(call);
  }

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() call, {
    T Function(dynamic data)? parser,
    bool trackLoading = true,
  }) async {
    final response = await _guard(call, trackLoading: trackLoading);
    final data = ApiEnvelope.dataOf(response);
    if (parser != null) return parser(data);
    return data as T;
  }

  Future<Response<dynamic>> _guard(
    Future<Response<dynamic>> Function() call, {
    bool trackLoading = true,
  }) async {
    await _connectivity.ensureOnline();
    if (trackLoading) _loading.begin();
    try {
      return await call();
    } on DioException catch (e) {
      throw ApiEnvelope.fromDio(e);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(e.toString());
    } finally {
      if (trackLoading) _loading.end();
    }
  }
}

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    dio: ref.watch(dioProvider),
    connectivity: ref.watch(connectivityServiceProvider),
    loading: ref.watch(networkLoadingProvider.notifier),
  );
});
