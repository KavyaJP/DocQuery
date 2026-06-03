class ApiConfig {
  static const String rootUrl = 'http://localhost:8000';

  static const String baseUrl = '$rootUrl/api';

  static const _ollamaAPIPrefix = 'v1/models';
  static const _documentAPIPrefix = 'v1/documents';
  static const _chatAPIPrefix = 'v1/chat';

  static const String localModels = '$baseUrl/$_ollamaAPIPrefix/local_models';
  static const String recommendedModels =
      '$baseUrl/$_ollamaAPIPrefix/recommended_models';
  static const String pullModel = '$baseUrl/$_ollamaAPIPrefix/pull';
  static const String removeModel = '$baseUrl/$_ollamaAPIPrefix/remove';

  static const String uploadDocument = '$baseUrl/$_documentAPIPrefix/upload';

  static const String chatAsk = '$baseUrl/$_chatAPIPrefix/ask';
}
