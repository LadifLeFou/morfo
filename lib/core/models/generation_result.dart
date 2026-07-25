import 'morfo_category.dart';
import 'template.dart';

/// Résultat d'une génération — persistable (JSON) pour l'historique offline.
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
    this.localPath,
  });

  final String id;
  final String templateId;
  final String templateTitle;
  final MorfoCategory category;

  /// http(s), chemin de fichier local, ou marqueur de démo `morfo://…`.
  ///
  /// Attention : en mode réel c'est une URL proxy vers Replicate, **temporaire**
  /// (elle expire au bout de ~1 h). Pour l'affichage durable, voir [localPath]
  /// et [displayUrl].
  final String outputUrl;
  final TemplateKind kind;
  final DateTime createdAt;

  /// Image source locale (pour le comparateur avant/après).
  final String? sourcePath;

  /// Copie locale du résultat, téléchargée après génération.
  ///
  /// Indispensable à l'historique : sans elle, une création ouverte le
  /// lendemain afficherait une image morte, l'URL Replicate ayant expiré.
  final String? localPath;

  bool get isVideo => kind == TemplateKind.video;

  /// URL à afficher : la copie locale si elle existe, sinon la source distante.
  String get displayUrl => localPath ?? outputUrl;

  GenerationResult copyWith({String? localPath}) => GenerationResult(
        id: id,
        templateId: templateId,
        templateTitle: templateTitle,
        category: category,
        outputUrl: outputUrl,
        kind: kind,
        createdAt: createdAt,
        sourcePath: sourcePath,
        localPath: localPath ?? this.localPath,
      );

  factory GenerationResult.fromJson(Map<String, dynamic> j) => GenerationResult(
        id: j['id'] as String,
        templateId: j['template_id'] as String,
        templateTitle: j['template_title'] as String,
        category: MorfoCategory.fromLabel((j['category'] as String?) ?? 'fun'),
        outputUrl: j['output_url'] as String,
        kind: TemplateKind.fromString(j['kind'] as String?),
        createdAt:
            DateTime.fromMillisecondsSinceEpoch((j['created_at'] as num).toInt()),
        sourcePath: j['source_path'] as String?,
        localPath: j['local_path'] as String?,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'template_id': templateId,
        'template_title': templateTitle,
        // On stocke le nom stable de l'enum, pas le libellé traduit : sinon une
        // création faite en anglais se rechargerait dans la mauvaise catégorie.
        'category': category.name,
        'output_url': outputUrl,
        'kind': kind.asString,
        'created_at': createdAt.millisecondsSinceEpoch,
        'source_path': sourcePath,
        'local_path': localPath,
      };
}
