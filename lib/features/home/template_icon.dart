import 'package:flutter/material.dart';

import '../../core/models/morfo_category.dart';
import '../../core/models/template.dart';

/// Icône représentative d'un style (vignettes / fallback).
IconData iconForTemplate(Template t) => switch (t.id) {
      'yearbook' => Icons.school_outlined,
      'flash_wedding' => Icons.favorite_outline,
      'linkedin' => Icons.badge_outlined,
      'digicam' => Icons.photo_camera_outlined,
      'macbook_selfie' => Icons.laptop_outlined,
      'old_money' => Icons.diamond_outlined,
      'golden_hour' => Icons.wb_sunny_outlined,
      'prom' => Icons.celebration_outlined,
      'selfie_star' => Icons.star_outline,
      'luxe' => Icons.workspace_premium_outlined,
      'gta' => Icons.sports_esports_outlined,
      'minecraft' => Icons.grid_view_outlined,
      'renaissance' => Icons.palette_outlined,
      'blockbuster' => Icons.local_movies_outlined,
      _ => iconForCategory(t.category),
    };

IconData iconForCategory(MorfoCategory c) => switch (c) {
      MorfoCategory.tendance => Icons.trending_up,
      MorfoCategory.aesthetic => Icons.auto_awesome_outlined,
      MorfoCategory.fun => Icons.mood_outlined,
      MorfoCategory.jeux => Icons.sports_esports_outlined,
      MorfoCategory.cinema => Icons.movie_outlined,
    };

/// Asset de la vraie photo « avant » — propre à chaque style.
String beforePreview(String templateId) =>
    'assets/images/preview_${templateId}_before.jpg';

/// Asset de l'exemple « après » — transformation adaptée au style.
String afterPreview(String templateId) =>
    'assets/images/preview_${templateId}_after.jpg';
