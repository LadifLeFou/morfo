import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/app_state.dart';
import '../../../core/models/template.dart';
import '../../../design_system/design_system.dart';
import '../../notifications/conversion_notifications.dart';
import '../generate_args.dart';
import '../../../core/strings.dart';
import '../../../core/image_prep.dart';

/// Import photo — caméra / galerie, permissions gérées, downscale avant envoi.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key, required this.template});

  final Template template;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _star = TextEditingController();
  XFile? _picked;
  Uint8List? _bytes;
  String? _error;

  /// Style « selfie avec une star » : l'utilisateur décrit la célébrité.
  bool get _isStar => widget.template.id == 'selfie_star';

  /// Le style star exige une description de la star avant de générer.
  bool get _starReady => !_isStar || _star.text.trim().isNotEmpty;

  @override
  void dispose() {
    _star.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _error = null);
    try {
      // Pas de redimensionnement ici : `image_picker` ré-encode sans toujours
      // appliquer l'EXIF. On lit l'original et on normalise nous-mêmes.
      final XFile? file = await _picker.pickImage(source: source);
      if (file == null) return;
      // Oriente les pixels + borne la taille : ce que voit le modèle est
      // exactement ce que voit l'utilisateur.
      final Uint8List bytes = await prepareForUpload(await file.readAsBytes());
      if (!mounted) return;
      setState(() {
        _picked = file;
        _bytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = S.photoAccessError);
    }
  }

  void _proceed() {
    final Uint8List? bytes = _bytes;
    if (bytes == null) return;
    final int cost = widget.template.creditCost;
    if (ref.read(creditsProvider) < cost) {
      ref.read(conversionNotificationsProvider).onCreditsEmpty();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.insufficientCredits)),
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
        customPrompt: _isStar ? _star.text.trim() : null,
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
          tooltip: S.back,
        ),
        title: Text(S.yourPhoto),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.xxl, Gap.xl, Gap.xxl),
        child: Column(
          children: <Widget>[
            _StyleHeader(template: widget.template),
            Gap.h24,
            if (_isStar) ...<Widget>[
              _starField(),
              Gap.h24,
            ],
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
                label: S.generateFor(widget.template.creditCost),
                icon: Icons.auto_awesome,
                onPressed: _starReady ? _proceed : null,
              ),
              if (_isStar && !_starReady) ...<Widget>[
                Gap.h8,
                Text(S.describeStarFirst,
                    style:
                        MorfoType.caption.copyWith(color: MorfoColors.muted)),
              ],
              Gap.h12,
              TextButton(
                onPressed: () => setState(() {
                  _picked = null;
                  _bytes = null;
                }),
                child: Text(S.chooseAnotherPhoto, style: MorfoType.label),
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

  /// Champ dédié au style star : l'utilisateur ne décrit QUE la célébrité.
  Widget _starField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(S.whichStar, style: MorfoType.eyebrow),
        Gap.h8,
        TextField(
          controller: _star,
          onChanged: (_) => setState(() {}),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
          style: MorfoType.bodyLarge,
          cursorColor: MorfoColors.holoViolet,
          decoration: InputDecoration(
            hintText: S.whichStarHint,
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
        Gap.h8,
        Text(
          S.whichStarHelp,
          style: MorfoType.caption.copyWith(color: MorfoColors.muted),
        ),
      ],
    );
  }

  Widget _chooser() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _OptionCard(
          icon: Icons.photo_library_outlined,
          label: S.fromGallery,
          onTap: () => _pick(ImageSource.gallery),
        ),
        Gap.h16,
        _OptionCard(
          icon: Icons.photo_camera_outlined,
          label: S.takePhoto,
          onTap: () => _pick(ImageSource.camera),
        ),
      ],
    );
  }
}

/// En-tête d'import : vignette « après » du style + nom, pour rappeler le
/// résultat visé et donner envie d'aller au bout.
class _StyleHeader extends StatelessWidget {
  const _StyleHeader({required this.template});

  final Template template;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: Radii.brMd,
          child: SizedBox(
            width: 56,
            height: 56,
            child: Image.asset(
              'assets/images/preview_${template.id}_after.jpg',
              fit: BoxFit.cover,
              errorBuilder: (BuildContext _, Object _, StackTrace? _) =>
                  HoloPlaceholder(seed: template.id),
            ),
          ),
        ),
        Gap.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(S.chosenStyle, style: MorfoType.eyebrow),
              const SizedBox(height: 2),
              Text(template.displayTitle, style: MorfoType.titleSmall),
            ],
          ),
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
