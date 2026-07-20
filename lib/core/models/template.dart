import 'morfo_category.dart';
import '../strings.dart';

/// Nature d'un template : image fixe ou courte vidéo.
enum TemplateKind {
  image,
  video;

  static TemplateKind fromString(String? s) =>
      s == 'video' ? TemplateKind.video : TemplateKind.image;

  String get asString => this == TemplateKind.video ? 'video' : 'image';
}

/// Un template de transformation (contrat §5 : `GET /templates`).
class Template {
  const Template({
    required this.id,
    required this.title,
    required this.category,
    this.description = '',
    this.thumbnailUrl = '',
    this.kind = TemplateKind.image,
    this.creditCost = 45,
    this.hero = false,
  });

  final String id;
  final String title;
  final String description;
  final MorfoCategory category;
  final String thumbnailUrl;
  final TemplateKind kind;
  final int creditCost;

  /// Template « héros » mis en tête de la home (la transfo la plus caractéristique).
  final bool hero;

  /// Titre affiché — retraduit depuis [id] quand la langue n'est pas le
  /// français, le backend ne servant que du français. Voir `S.templateTitle`.
  String get displayTitle => S.templateTitle(id, title);

  /// Description affichée, même principe que [displayTitle].
  String get displayDescription => S.templateDescription(id, description);

  bool get isVideo => kind == TemplateKind.video;
  bool get hasThumbnail => thumbnailUrl.isNotEmpty;

  factory Template.fromJson(Map<String, dynamic> j) => Template(
        id: j['id'] as String,
        title: j['title'] as String,
        description: (j['description'] as String?) ?? '',
        category: MorfoCategory.fromLabel((j['category'] as String?) ?? 'Fun'),
        thumbnailUrl: (j['thumbnail_url'] as String?) ?? '',
        kind: TemplateKind.fromString(j['kind'] as String?),
        creditCost: (j['credit_cost'] as num?)?.toInt() ?? 45,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'description': description,
        'category': category.label,
        'thumbnail_url': thumbnailUrl,
        'kind': kind.asString,
        'credit_cost': creditCost,
      };
}
