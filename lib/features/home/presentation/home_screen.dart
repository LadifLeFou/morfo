import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../app/widgets/credits_badge.dart';
import '../../../core/models/morfo_category.dart';
import '../../../core/models/template.dart';
import '../../../design_system/design_system.dart';
import '../template_icon.dart';

/// Home — grille éditoriale de templates, template héros en tête, chips, recherche.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';
  MorfoCategory? _category;

  bool get _isFront => _category == null && _query.isEmpty;

  List<Template> _filter(List<Template> all) {
    final String q = _query.toLowerCase();
    return all.where((Template t) {
      final bool okCat = _category == null || t.category == _category;
      final bool okQuery = q.isEmpty || t.title.toLowerCase().contains(q);
      return okCat && okQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Template>> templates = ref.watch(templatesProvider);

    return MorfoScaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _TopBar()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.md),
              child: _SearchField(
                onChanged: (String v) => setState(() => _query = v),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _CategoryBar(
              selected: _category,
              onSelected: (MorfoCategory? c) => setState(() => _category = c),
            ),
          ),
          ...templates.when(
            data: (List<Template> all) => _content(all),
            loading: () => const <Widget>[_LoadingSlivers()],
            error: (Object e, StackTrace _) => <Widget>[
              const _ErrorSliver(),
            ],
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.giant)),
        ],
      ),
    );
  }

  List<Widget> _content(List<Template> all) {
    final List<Template> filtered = _filter(all);
    final Template? hero =
        _isFront ? all.where((Template t) => t.hero).firstOrNull : null;
    final List<Template> grid = hero == null
        ? filtered
        : filtered.where((Template t) => !t.hero).toList();

    if (filtered.isEmpty) {
      return <Widget>[const _EmptySliver()];
    }

    return <Widget>[
      if (hero != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.lg),
            child: _HeroTile(template: hero),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: Gap.md,
            crossAxisSpacing: Gap.md,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int i) => _TemplateTile(template: grid[i]),
            childCount: grid.length,
          ),
        ),
      ),
    ];
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.md, Gap.md, Gap.sm),
      child: Row(
        children: <Widget>[
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (Rect b) => MorfoColors.holoGradient.createShader(b),
            child: Text(
              'Morfo',
              style: MorfoType.titleLarge.copyWith(color: Colors.white),
            ),
          ),
          const Spacer(),
          const CreditsBadge(),
          IconButton(
            onPressed: () => context.push('/history'),
            icon: const Icon(Icons.history, color: MorfoColors.ink),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined, color: MorfoColors.ink),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: MorfoType.bodyLarge,
      cursorColor: MorfoColors.holoViolet,
      decoration: InputDecoration(
        hintText: 'Rechercher un style',
        hintStyle: MorfoType.bodyLarge.copyWith(color: MorfoColors.muted),
        prefixIcon: const Icon(Icons.search, color: MorfoColors.muted),
        filled: true,
        fillColor: MorfoColors.surface.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(vertical: Gap.lg),
        enabledBorder: OutlineInputBorder(
          borderRadius: Radii.brMd,
          borderSide: const BorderSide(color: MorfoColors.stroke),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: Radii.brMd,
          borderSide: const BorderSide(color: MorfoColors.holoViolet),
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.selected, required this.onSelected});
  final MorfoCategory? selected;
  final ValueChanged<MorfoCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        children: <Widget>[
          CategoryChip(
            label: 'Tout',
            selected: selected == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: Gap.sm),
          for (final MorfoCategory c in MorfoCategory.values) ...<Widget>[
            CategoryChip(
              label: c.label,
              selected: selected == c,
              onTap: () => onSelected(c),
            ),
            const SizedBox(width: Gap.sm),
          ],
        ],
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  const _HeroTile({required this.template});
  final Template template;

  @override
  Widget build(BuildContext context) {
    return HoloCard(
      aspectRatio: 5 / 6,
      eyebrow: 'À la une · ${template.category.label}',
      title: template.title,
      onTap: () => context.push('/template', extra: template),
      child: Hero(
        tag: 'tpl_${template.id}',
        child: HoloPlaceholder(
          seed: template.id,
          icon: iconForTemplate(template),
        ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.template});
  final Template template;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: () => context.push('/template', extra: template),
      child: ClipRRect(
        borderRadius: Radii.brMd,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
              tag: 'tpl_${template.id}',
              child: HoloPlaceholder(
                seed: template.id,
                icon: iconForTemplate(template),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: MorfoColors.scrim),
            ),
            Positioned(
              left: Gap.md,
              right: Gap.md,
              bottom: Gap.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(template.category.label, style: MorfoType.eyebrow),
                  const SizedBox(height: 2),
                  Text(
                    template.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MorfoType.titleSmall,
                  ),
                ],
              ),
            ),
            Positioned(top: Gap.sm, right: Gap.sm, child: _CostTag(template: template)),
          ],
        ),
      ),
    );
  }
}

class _CostTag extends StatelessWidget {
  const _CostTag({required this.template});
  final Template template;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: MorfoColors.voidColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            template.isVideo ? Icons.slideshow : Icons.bolt,
            size: 13,
            color: MorfoColors.holoWarm,
          ),
          const SizedBox(width: 3),
          Text(
            template.isVideo ? 'Vidéo' : '${template.creditCost}',
            style: MorfoType.eyebrow.copyWith(fontSize: 11, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class _LoadingSlivers extends StatelessWidget {
  const _LoadingSlivers();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: Gap.md,
          crossAxisSpacing: Gap.md,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (BuildContext context, int i) =>
              const ShimmerSkeleton(borderRadius: Radii.brMd, height: 999),
          childCount: 6,
        ),
      ),
    );
  }
}

class _EmptySliver extends StatelessWidget {
  const _EmptySliver();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.giant, Gap.xl, 0),
        child: Column(
          children: <Widget>[
            const Icon(Icons.search_off, size: 40, color: MorfoColors.muted),
            Gap.h12,
            Text('Aucun style ne correspond.', style: MorfoType.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _ErrorSliver extends StatelessWidget {
  const _ErrorSliver();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.giant, Gap.xl, 0),
        child: Column(
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 40, color: MorfoColors.muted),
            Gap.h12,
            Text('Impossible de charger les styles.',
                style: MorfoType.bodyMedium),
          ],
        ),
      ),
    );
  }
}
