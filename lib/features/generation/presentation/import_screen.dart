import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_state.dart';
import '../../../core/models/template.dart';
import '../../../design_system/design_system.dart';
import '../generate_args.dart';

/// Import photo — caméra / galerie, permissions gérées, downscale avant envoi.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key, required this.template});

  final Template template;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _picked;
  Uint8List? _bytes;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      // Optimisation dès la sélection : max 1024 px + JPEG q≈0.8.
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
      if (!mounted) return;
      setState(() => _error =
          'Accès à la photo impossible. Vérifie les autorisations.');
    }
  }

  void _proceed() {
    final Uint8List? bytes = _bytes;
    if (bytes == null) return;
    final int cost = widget.template.creditCost;
    if (ref.read(creditsProvider) < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Crédits insuffisants.')),
      );
      context.push('/credits');
      return;
    }
    context.push(
      '/generate',
      extra: GenerateArgs(
        template: widget.template,
        bytes: bytes,
        sourcePath: _picked?.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = _bytes != null;
    return MorfoScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Ta photo'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xxl, Gap.xl, Gap.xxl),
        child: Column(
          children: <Widget>[
            Text(
              'Style choisi : ${widget.template.title}',
              style: MorfoType.bodyMedium,
            ),
            Gap.h24,
            Expanded(
              child: hasPhoto ? _preview() : _chooser(),
            ),
            if (_error != null) ...<Widget>[
              Gap.h12,
              Text(_error!,
                  style: MorfoType.caption.copyWith(color: MorfoColors.danger)),
            ],
            Gap.h24,
            if (hasPhoto) ...<Widget>[
              GradientButton(
                label: 'Générer · ${widget.template.creditCost} crédit'
                    '${widget.template.creditCost > 1 ? 's' : ''}',
                icon: Icons.auto_awesome,
                onPressed: _proceed,
              ),
              Gap.h12,
              TextButton(
                onPressed: () => setState(() {
                  _picked = null;
                  _bytes = null;
                }),
                child: Text('Choisir une autre photo', style: MorfoType.label),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _preview() {
    return ClipRRect(
      borderRadius: Radii.brLg,
      child: MorfoImage(url: _picked!.path),
    );
  }

  Widget _chooser() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _OptionCard(
          icon: Icons.photo_library_outlined,
          label: 'Depuis la galerie',
          onTap: () => _pick(ImageSource.gallery),
        ),
        Gap.h16,
        _OptionCard(
          icon: Icons.photo_camera_outlined,
          label: 'Prendre une photo',
          onTap: () => _pick(ImageSource.camera),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: Gap.xxl),
        decoration: BoxDecoration(
          color: MorfoColors.surface2.withValues(alpha: 0.5),
          borderRadius: Radii.brLg,
          border: Border.all(color: MorfoColors.stroke),
        ),
        child: Column(
          children: <Widget>[
            Icon(icon, size: 34, color: MorfoColors.holoViolet),
            Gap.h12,
            Text(label, style: MorfoType.titleSmall),
          ],
        ),
      ),
    );
  }
}
