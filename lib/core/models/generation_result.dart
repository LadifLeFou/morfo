import 'morfo_category.dart';
import 'template.dart';

/// Résultat d'une génération — persistable (JSON/Hive) pour l'historique offline.
class GenerationResult {
  const GenerationResult({
    required this.id,
    required this.templateId,
    required this.templateTitle,
    required this.category,
    required this.outputUrl,
    required this.kind,
    required this.createdAt,
    this.sourcePath,
  });

  final String id;
  final String templateId;
  final String templateTitle;
  final MorfoCategory category;

  /// http(s), chemin de fichier local, ou marqueur de démo `morfo://…`.
  final String outputUrl;
  final TemplateKind kind;
  final DateTime createdAt;

  /// Image source locale (pour le comparateur avant/après).
  final String? sourcePath;

  bool get isVideo => kind == TemplateKind.video;

  factory GenerationResult.fromJson(Map<String, dynamic> j) => GenerationResult(
        id: j['id'] as String,
        templateId: j['template_id'] as String,
        templateTitle: j['template_title'] as String,
        category: MorfoCategory.fromLabel((j['category'] as String?) ?? 'Fun'),
        outputUrl: j['output_url'] as String,
        kind: TemplateKind.fromString(j['kind'] as String?),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch((j['created_at'] as num).toInt()),
        sourcePath: j['source_path'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'template_id': templateId,
        'template_title': templateTitle,
        'category': category.label,
        'output_url': outputUrl,
        'kind': kind.asString,
        'created_at': createdAt.millisecondsSinceEpoch,
        'source_path': sourcePath,
      };
}
