import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:doc_query/config/api_config.dart';

class LocalModel {
  final String name;
  final int sizeInBytes;
  final String parameterSize;

  LocalModel({
    required this.name,
    required this.sizeInBytes,
    required this.parameterSize,
  });

  factory LocalModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> details = json['details'] is Map
        ? json['details'] as Map<String, dynamic>
        : <String, dynamic>{};

    return LocalModel(
      name: json['name']?.toString() ?? 'Unknown Model',
      sizeInBytes: json['size'] is int ? json['size'] as int : 0,
      parameterSize: details['parameter_size']?.toString() ?? 'N/A',
    );
  }

  String get formattedSize {
    if (sizeInBytes == 0) return "0 GB";
    final double gb = sizeInBytes / (1024 * 1024 * 1024);
    return '${gb.toStringAsFixed(2)} GB';
  }
}

class ModelsService {
  final Dio _dio = Dio();

  Future<List<LocalModel>> fetchLocalModels() async {
    try {
      final response = await _dio.get(ApiConfig.localModels);
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      final List<dynamic> modelList = data['models'] is List
          ? data['models'] as List<dynamic>
          : [];

      return modelList
          .map((item) => LocalModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to load local modals: $e');
    }
  }

  Future<Map<String, dynamic>> fetchRecommendedModels() async {
    try {
      final response = await _dio.get(ApiConfig.recommendedModels);
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;

      return data.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      throw Exception('Failed to fetch Recommended Model list: $e');
    }
  }

  Future<void> removeOllamaModel(String modelName) async {
    try {
      await _dio.post(ApiConfig.removeModel, data: {'name': modelName});
    } catch (e) {
      throw Exception('Failed to remove ollama model: $e');
    }
  }

  Stream<double> pullModelStream(String modelName) async* {
    final response = await _dio.post<ResponseBody>(
      ApiConfig.pullModel,
      data: {"name": modelName},
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data?.stream;
    if (stream == null) {
      throw Exception('No data sent from the server.');
    }

    final LineSplitter lineSplitter = LineSplitter();

    await for (final List<int> bytes in stream) {
      final String rawText = utf8.decode(bytes);
      final List<String> lines = lineSplitter.convert(rawText);

      for (final String line in lines) {
        if (line.trim().isEmpty) continue;

        try {
          final Map<String, dynamic> jsonStatus =
              jsonDecode(line) as Map<String, dynamic>;

          if (jsonStatus.containsKey('completed') &&
              jsonStatus.containsKey('total')) {

            final int completed = jsonStatus['completed'] is int
                ? jsonStatus['completed'] as int
                : 0;
            final int total = jsonStatus['total'] is int
                ? jsonStatus['total'] as int
                : 1;

            if (total > 0) {
              yield completed / total;
            }
          }
        } catch (_) {}
      }
    }
  }
}
