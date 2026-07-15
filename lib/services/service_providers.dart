import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/env.dart';
import 'generation_service.dart';
import 'generation_service_api.dart';
import 'generation_service_mock.dart';

/// Client HTTP configuré (timeouts + auth). Utilisé par l'API réelle.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 60),
      headers: <String, dynamic>{
        'Authorization': 'Bearer ${Env.supabaseAnonKey}',
      },
    ),
  );
});

/// Renvoie le mock ou l'API réelle selon `MORFO_USE_MOCK`.
final Provider<GenerationService> generationServiceProvider =
    Provider<GenerationService>((Ref ref) {
  if (Env.useMock) return MockGenerationService();
  return ApiGenerationService(ref.read(dioProvider));
});
