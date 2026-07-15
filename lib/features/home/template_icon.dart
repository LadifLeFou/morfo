import 'package:flutter/material.dart';

import '../../core/models/morfo_category.dart';
import '../../core/models/template.dart';

/// Icône représentative d'un template (pour les vignettes placeholder).
IconData iconForTemplate(Template t) => switch (t.id) {
      'epic_warrior' => Icons.shield_outlined,
      'astronaut' => Icons.rocket_launch_outlined,
      'royalty' => Icons.diamond_outlined,
      'cyberpunk' => Icons.bolt_outlined,
      'yearbook_90s' => Icons.school_outlined,
      'polaroid_70s' => Icons.photo_outlined,
      'vhs' => Icons.videocam_outlined,
      'bodybuilder' => Icons.fitness_center_outlined,
      'baby' => Icons.child_care_outlined,
      'aging_plus50' => Icons.elderly_outlined,
      'pixar' => Icons.smart_toy_outlined,
      'studio_portrait' => Icons.face_outlined,
      'perfect_skin' => Icons.auto_fix_high_outlined,
      'golden_hour' => Icons.wb_sunny_outlined,
      'film_noir' => Icons.movie_outlined,
      'blockbuster' => Icons.local_movies_outlined,
      'anime' => Icons.brush_outlined,
      'living_portrait' => Icons.slideshow_outlined,
      _ => iconForCategory(t.category),
    };

IconData iconForCategory(MorfoCategory c) => switch (c) {
      MorfoCategory.epique => Icons.shield_outlined,
      MorfoCategory.retro => Icons.camera_outlined,
      MorfoCategory.fun => Icons.mood_outlined,
      MorfoCategory.glow => Icons.auto_awesome_outlined,
      MorfoCategory.cinema => Icons.movie_outlined,
      MorfoCategory.video => Icons.slideshow_outlined,
    };
