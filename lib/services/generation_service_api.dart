import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../core/app_exception.dart';
import '../core/models/generation_result.dart';
import '../core/models/template.dart';
import 'generation_service.dart';

/// Implémentation réelle contre le backend (contrat §5).
///
/// Branchée quand `MORFO_USE_MOCK=false`. L'app n'envoie que l'identifiant
/// utilisateur, l'id de template et l'image.
class ApiGenerationService implements GenerationService {
  ApiGenerationService(this._dio);

  final Dio _dio;

  @override
  Future<List<Template>> fetchTemplates() async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>('/templates');
      final List<dynamic> data = res.data as List<dynamic>;
      return data
          .map((dynamic e) => Template.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw AppException('Impossible de charger les styles.', cause: e);
    }
  }

  @override
  Future<GenerationOutcome> generateImage({
    required Template template,
    required Uint8List imageBytes,
    required String userId,
    String? sourcePath,
  }) async {
    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        '/generate-image',
        data: <String, dynamic>{
          'rc_app_user_id': userId,
          'template_id': template.id,
          'image_base64': base64Encode(imageBytes),
        },
      );
      final Map<String, dynamic> j = res.data as Map<String, dynamic>;
      final GenerationResult result = GenerationResult(
        id: _newId(),
        templateId: template.id,
        templateTitle: template.title,
        category: template.category,
        outputUrl: j['url'] as String,
        kind: template.kind,
        createdAt: DateTime.now(),
        sourcePath: sourcePath,
      );
      return GenerationOutcome(
        result,
        (j['credits_left'] as num?)?.toInt() ?? -1,
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<String> submitVideo({
    required Template template,
    required Uint8List imageBytes,
    required String userId,
  }) async {
    try {
      final Response<dynamic> res = await _dio.post<dynamic>(
        '/generate-video',
        data: <String, dynamic>{
          'rc_app_user_id': userId,
          'template_id': template.id,
          'image_base64': base64Encode(imageBytes),
        },
      );
      return (res.data as Map<String, dynamic>)['request_id'] as String;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<VideoStatus> pollVideo(String requestId) async {
    try {
      final Response<dynamic> res = await _dio.get<dynamic>(
        '/video-status',
        queryParameters: <String, dynamic>{'id': requestId},
      );
      return VideoStatus.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException('Le suivi de la vidéo a été interrompu.', cause: e);
    }
  }

  AppException _mapError(DioException e) {
    if (e.response?.statusCode == 402) {
      return const AppException(
        'Crédits insuffisants.',
        insufficientCredits: true,
      );
    }
    return AppException('La génération a échoué. Réessaie.', cause: e);
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}';
}
