import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio = Dio();

  // Constructor: Initializes Dio with default configuration options
  DioClient() {
    _dio.options = BaseOptions(
      baseUrl: "http://10.175.53.182:4000/api/auth", // Default base URL for API
      connectTimeout: Duration(seconds: 5000), // Connection timeout duration
      receiveTimeout: Duration(
        seconds: 3000,
      ), // Data receiving timeout duration
      headers: {"Content-Type": "application/json"}, // Default request headers
    );
  }

  /// GET Request: Fetches data from the specified endpoint.
  /// [endpoint] - API endpoint to call.
  /// [params] - Query parameters to send with the request.
  Future<Response> get(String endpoint, {Map<String, dynamic>? params}) async {
    return await safeRequest(() => _dio.get(endpoint, queryParameters: params));
  }

  /// POST Request: Sends data to the server to create a new resource.
  /// [endpoint] - API endpoint to call.
  /// [data] - Data payload to send in the request body.
  Future<Response> post(String endpoint, {dynamic data}) async {
    return await safeRequest(() => _dio.post(endpoint, data: data));
  }

  /// PUT Request: Updates an existing resource on the server.
  /// [endpoint] - API endpoint to call.
  /// [data] - Data payload to send in the request body.
  Future<Response> put(String endpoint, {dynamic data}) async {
    return await safeRequest(() => _dio.put(endpoint, data: data));
  }

  /// DELETE Request: Deletes a resource from the server.
  /// [endpoint] - API endpoint to call.
  /// [params] - Query parameters to send with the request.
  Future<Response> delete(
    String endpoint, {
    Map<String, dynamic>? params,
  }) async {
    return await safeRequest(
      () => _dio.delete(endpoint, queryParameters: params),
    );
  }

  /// PATCH Request: Partially updates a resource on the server.
  /// [endpoint] - API endpoint to call.
  /// [data] - Data payload to send in the request body.
  Future<Response> patch(String endpoint, {dynamic data}) async {
    return await safeRequest(() => _dio.patch(endpoint, data: data));
  }

  /// HEAD Request: Fetches headers of a resource without the response body.
  /// [endpoint] - API endpoint to call.
  /// [params] - Query parameters to send with the request.
  Future<Response> head(String endpoint, {Map<String, dynamic>? params}) async {
    return await safeRequest(
      () => _dio.head(endpoint, queryParameters: params),
    );
  }

  /// Safe Request Wrapper: Handles errors for any Dio request.
  /// [requestFunction] - A function that performs the actual Dio request.
  Future<Response> safeRequest(
    Future<Response> Function() requestFunction,
  ) async {
    try {
      return await requestFunction(); // Perform the request
    } on DioError catch (e) {
      // Dio-specific error handling
      print("DioError: ${e.message}");
      return e.response!;
    } catch (e) {
      // Generic error handling
      print("Unexpected error: $e");
      rethrow;
    }
  }

  /// Set Base URL: Updates the base URL dynamically.
  /// [url] - New base URL for the API requests.
  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  /// Set Headers: Adds or updates request headers dynamically.
  /// [headers] - A map of header key-value pairs to add or modify.
  void setHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }
}
