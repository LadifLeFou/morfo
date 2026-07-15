import '../core/models/morfo_category.dart';
import '../core/models/template.dart';

/// ~18 templates de démo aux titres FR réels — pas de « template IA générique ».
/// Utilisés par le service mock pour faire tourner l'app sans backend.
const List<Template> demoTemplates = <Template>[
  // — Épique —
  Template(
    id: 'epic_warrior',
    title: 'Guerrier épique',
    description: 'Armure de bataille et lumière cinématographique.',
    category: MorfoCategory.epique,
    hero: true,
  ),
  Template(
    id: 'astronaut',
    title: 'Astronaute',
    description: 'Combinaison spatiale, reflets d’étoiles.',
    category: MorfoCategory.epique,
  ),
  Template(
    id: 'royalty',
    title: 'Roi / Reine',
    description: 'Portrait royal, or et velours.',
    category: MorfoCategory.epique,
  ),
  Template(
    id: 'cyberpunk',
    title: 'Cyberpunk',
    description: 'Néons de la mégalopole, pluie et chrome.',
    category: MorfoCategory.epique,
  ),

  // — Rétro —
  Template(
    id: 'yearbook_90s',
    title: 'Yearbook 90s',
    description: 'Photo de classe américaine, grain d’époque.',
    category: MorfoCategory.retro,
  ),
  Template(
    id: 'polaroid_70s',
    title: 'Polaroid 70s',
    description: 'Teintes chaudes et bord blanc.',
    category: MorfoCategory.retro,
  ),
  Template(
    id: 'vhs',
    title: 'VHS',
    description: 'Balayage cathodique, date incrustée.',
    category: MorfoCategory.retro,
  ),

  // — Fun —
  Template(
    id: 'bodybuilder',
    title: 'Bodybuilder',
    description: 'Muscles improbables, scène assumée.',
    category: MorfoCategory.fun,
  ),
  Template(
    id: 'baby',
    title: 'Bébé',
    description: 'Une version adorable et joufflue.',
    category: MorfoCategory.fun,
  ),
  Template(
    id: 'aging_plus50',
    title: 'Vieillissement +50 ans',
    description: 'Un aperçu du futur, rides comprises.',
    category: MorfoCategory.fun,
  ),
  Template(
    id: 'pixar',
    title: 'Personnage Pixar',
    description: 'Grands yeux, rendu 3D chaleureux.',
    category: MorfoCategory.fun,
  ),

  // — Glow —
  Template(
    id: 'studio_portrait',
    title: 'Portrait studio',
    description: 'Éclairage doux sur fond neutre.',
    category: MorfoCategory.glow,
  ),
  Template(
    id: 'perfect_skin',
    title: 'Peau parfaite',
    description: 'Retouche naturelle, éclat sain.',
    category: MorfoCategory.glow,
  ),
  Template(
    id: 'golden_hour',
    title: 'Golden hour',
    description: 'Lumière dorée de fin de journée.',
    category: MorfoCategory.glow,
  ),

  // — Cinéma —
  Template(
    id: 'film_noir',
    title: 'Film noir',
    description: 'Noir et blanc contrasté, ombres nettes.',
    category: MorfoCategory.cinema,
  ),
  Template(
    id: 'blockbuster',
    title: 'Blockbuster',
    description: 'Étalonnage teal & orange, grand spectacle.',
    category: MorfoCategory.cinema,
  ),
  Template(
    id: 'anime',
    title: 'Anime',
    description: 'Traits stylisés, couleurs vives.',
    category: MorfoCategory.cinema,
  ),

  // — Vidéo —
  Template(
    id: 'living_portrait',
    title: 'Portrait vivant',
    description: 'Une courte animation de 5 secondes.',
    category: MorfoCategory.video,
    kind: TemplateKind.video,
    creditCost: 15,
  ),
];
