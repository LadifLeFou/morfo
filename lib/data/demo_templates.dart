import '../core/models/morfo_category.dart';
import '../core/models/template.dart';

/// Catalogue de styles tendance (type Ora AI).
const List<Template> demoTemplates = <Template>[
  // — Tendance —
  Template(
    id: 'yearbook',
    title: 'Yearbook 90s',
    description: 'Photo de classe américaine, grain rétro assumé.',
    category: MorfoCategory.tendance,
    hero: true,
  ),
  Template(
    id: 'flash_wedding',
    title: 'Flash wedding',
    description: 'Portrait de mariage au flash, chaleureux.',
    category: MorfoCategory.tendance,
  ),
  Template(
    id: 'linkedin',
    title: 'LinkedIn pro',
    description: 'Portrait professionnel, tenue business.',
    category: MorfoCategory.tendance,
  ),

  // — Aesthetic —
  Template(
    id: 'digicam',
    title: 'Digital camera',
    description: 'Flash appareil photo 2000s, ambiance soirée.',
    category: MorfoCategory.aesthetic,
  ),
  Template(
    id: 'macbook_selfie',
    title: 'MacBook selfie',
    description: 'Selfie webcam Photo Booth.',
    category: MorfoCategory.aesthetic,
  ),
  Template(
    id: 'old_money',
    title: 'Old money',
    description: 'Élégance intemporelle, luxe discret.',
    category: MorfoCategory.aesthetic,
  ),
  Template(
    id: 'golden_hour',
    title: 'Golden hour',
    description: 'Lumière dorée de fin de journée.',
    category: MorfoCategory.aesthetic,
  ),

  // — Fun —
  Template(
    id: 'prom',
    title: 'Prom',
    description: 'Photo de bal de promo, tenue de gala.',
    category: MorfoCategory.fun,
  ),
  Template(
    id: 'selfie_star',
    title: 'Selfie avec une star',
    description: 'Un selfie avec la célébrité de ton choix : décris-la, on s’occupe du reste.',
    category: MorfoCategory.fun,
    creditCost: 68, // style premium (×1,5 du coût image de base)
  ),

  // — Jeux —
  Template(
    id: 'gta',
    title: 'GTA V',
    description: 'Style écran de chargement GTA V.',
    category: MorfoCategory.jeux,
  ),
  Template(
    id: 'minecraft',
    title: 'Minecraft',
    description: 'Personnage et monde Minecraft.',
    category: MorfoCategory.jeux,
  ),

  // — Cinéma —
  Template(
    id: 'renaissance',
    title: 'Renaissance',
    description: 'Portrait peinture à l’huile classique.',
    category: MorfoCategory.cinema,
  ),
  Template(
    id: 'blockbuster',
    title: 'Blockbuster',
    description: 'Affiche de film hollywoodien.',
    category: MorfoCategory.cinema,
  ),
];
