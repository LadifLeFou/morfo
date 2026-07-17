import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_state.dart';
import '../../../core/models/morfo_category.dart';
import '../../../core/models/template.dart';
import '../../../design_system/design_system.dart';
import '../generate_args.dart';

const List<String> _suggestions = <String>[
  "en astronaute dans l'espace",
  'en personnage cyberpunk néon',
  "portrait renaissance à l'huile",
  'en super-héros de comics',
  'en roi médiéval, cinématographique',
  'style vieux film argentique',
];

/// Mode prompt libre — photo + prompt de l'utilisateur, en image ou en vidéo.
class CustomPromptScreen extends ConsumerStatefulWidget {
  const CustomPromptScreen({super.key});

  @override
  ConsumerState<CustomPromptScreen> createState() => _CustomPromptScreenState();
}

class _CustomPromptScreenState extends ConsumerState<CustomPromptScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _prompt = TextEditingController();
  XFile? _picked;
  Uint8List? _bytes;
  String? _error;
  bool _isVideo = false;

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (file == null) return;
      final Uint8List bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _picked = file;
        _bytes = bytes;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Accès à la photo impossible.');
      }
    }
  }

  void _generate() {
    final Uint8List? bytes = _bytes;
    final String prompt = _prompt.text.trim();
    if (bytes == null || prompt.isEmpty) return;

    final Template template = Template(
      id: 'custom',
      title: _isVideo ? 'Vidéo' : 'Prompt libre',
      category: MorfoCategory.fun,
      kind: _isVideo ? TemplateKind.video : TemplateKind.image,
      // Prompt libre : plus cher que les styles de base (vidéo la plus chère).
      creditCost: _isVideo ? 350 : 75,
    );

    if (ref.read(creditsProvider) < template.creditCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crédits insuffisants.')),
      );
      context.push('/credits');
      return;
    }
    context.push(
      '/generate',
      extra: GenerateArgs(
        template: template,
        bytes: bytes,
        sourcePath: _picked?.path,
        customPrompt: prompt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool ready = _bytes != null && _prompt.text.trim().isNotEmpty;
    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Prompt libre'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.lg, Gap.xl, Gap.giant),
        children: <Widget>[
          Text(
            'Importe ta photo, choisis Photo ou Vidéo, et décris ce que tu veux.',
            style: MorfoType.bodyMedium,
          ),
          Gap.h16,
          // Toggle Photo / Vidéo
          Row(
            children: <Widget>[
              Expanded(
                child: _modeChip('Photo', Icons.photo_outlined, !_isVideo,
                    () => setState(() => _isVideo = false)),
              ),
              Gap.w8,
              Expanded(
                child: _modeChip('Vidéo', Icons.videocam_outlined, _isVideo,
                    () => setState(() => _isVideo = true)),
              ),
            ],
          ),
          Gap.h24,
          if (_bytes == null) _pickerBox() else _preview(),
          Gap.h24,
          TextField(
            controller: _prompt,
            onChanged: (_) => setState(() {}),
            maxLines: 3,
            style: MorfoType.bodyLarge,
            cursorColor: MorfoColors.holoViolet,
            decoration: InputDecoration(
              hintText: _isVideo
                  ? 'Ex : il sourit et fait un clin d\'œil, la caméra zoome…'
                  : "Ex : en astronaute dans l'espace, cinématographique…",
              hintStyle: MorfoType.bodyMedium,
              filled: true,
              fillColor: MorfoColors.surface.withValues(alpha: 0.6),
              contentPadding: const EdgeInsets.all(Gap.lg),
              enabledBorder: OutlineInputBorder(
                borderRadius: Radii.brMd,
                borderSide: const BorderSide(color: MorfoColors.stroke),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: Radii.brMd,
                borderSide: const BorderSide(color: MorfoColors.holoViolet),
              ),
            ),
          ),
          if (!_isVideo) ...<Widget>[
            Gap.h16,
            Text('IDÉES', style: MorfoType.eyebrow),
            Gap.h12,
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.sm,
              children: <Widget>[
                for (final String s in _suggestions)
                  Pressable(
                    onTap: () {
                      _prompt.text = s;
                      setState(() {});
                    },
                    scale: 0.96,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Gap.md, vertical: Gap.sm),
                      decoration: BoxDecoration(
                        color: MorfoColors.surface2.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(Radii.pill),
                        border: Border.all(color: MorfoColors.stroke),
                      ),
                      child: Text(s, style: MorfoType.caption),
                    ),
                  ),
              ],
            ),
          ],
          if (_isVideo) ...<Widget>[
            Gap.h12,
            Text('La vidéo dure ~5 s et prend un peu plus de temps à générer.',
                style: MorfoType.caption),
          ],
          if (_error != null) ...<Widget>[
            Gap.h12,
            Text(_error!,
                style: MorfoType.caption.copyWith(color: MorfoColors.danger)),
          ],
          Gap.h24,
          GradientButton(
            label: _isVideo
                ? 'Générer la vidéo · 350 crédits'
                : 'Générer · 75 crédits',
            icon: _isVideo ? Icons.videocam : Icons.auto_awesome,
            onPressed: ready ? _generate : null,
          ),
        ],
      ),
    );
  }

  Widget _modeChip(String label, IconData icon, bool selected, VoidCallback onTap) {
    return Pressable(
      onTap: onTap,
      scale: 0.98,
      child: AnimatedContainer(
        duration: Motion.fast,
        padding: const EdgeInsets.symmetric(vertical: Gap.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? MorfoColors.ink.withValues(alpha: 0.06)
              : MorfoColors.surface.withValues(alpha: 0.5),
          borderRadius: Radii.brMd,
          border: Border.all(
            color: selected ? MorfoColors.holoViolet : MorfoColors.stroke,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon,
                size: 18,
                color: selected ? MorfoColors.ink : MorfoColors.muted),
            Gap.w8,
            Text(
              label,
              style: MorfoType.label.copyWith(
                color: selected ? MorfoColors.ink : MorfoColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerBox() {
    return Container(
      padding: const EdgeInsets.all(Gap.xxl),
      decoration: BoxDecoration(
        color: MorfoColors.surface2.withValues(alpha: 0.4),
        borderRadius: Radii.brLg,
        border: Border.all(color: MorfoColors.stroke),
      ),
      child: Column(
        children: <Widget>[
          const Icon(Icons.add_a_photo_outlined,
              size: 34, color: MorfoColors.holoViolet),
          Gap.h12,
          Text('Importe une photo', style: MorfoType.titleSmall),
          Gap.h16,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _miniButton(
                  'Galerie', Icons.photo_library_outlined, ImageSource.gallery),
              Gap.w12,
              _miniButton(
                  'Caméra', Icons.photo_camera_outlined, ImageSource.camera),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniButton(String label, IconData icon, ImageSource source) {
    return Pressable(
      onTap: () => _pick(source),
      scale: 0.96,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.md),
        decoration: BoxDecoration(
          color: MorfoColors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(Radii.pill),
          border: Border.all(color: MorfoColors.stroke),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: MorfoColors.ink),
            Gap.w8,
            Text(label, style: MorfoType.label),
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: Radii.brLg,
          child: AspectRatio(
            aspectRatio: 1,
            child: MorfoImage(url: _picked!.path),
          ),
        ),
        Gap.h8,
        TextButton(
          onPressed: () => setState(() {
            _picked = null;
            _bytes = null;
          }),
          child: Text('Changer la photo', style: MorfoType.label),
        ),
      ],
    );
  }
}
