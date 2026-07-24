import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_state.dart';
import '../../../app/widgets/credits_badge.dart';
import '../../../app/widgets/favorite_button.dart';
import '../../../core/models/morfo_category.dart';
import '../../../core/models/template.dart';
import '../../../core/strings.dart';
import '../../../design_system/design_system.dart';
import '../../notifications/conversion_notifications.dart';
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
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    // Utilisateur actif → repousse la relance d'inactivité, annule la bienvenue.
    ref.read(conversionNotificationsProvider).onActive(
          subscribed: ref.read(subscriptionProvider),
        );
  }

  bool get _isFront =>
      _category == null && _query.isEmpty && !_favoritesOnly;

  List<Template> _filter(List<Template> all, Set<String> favorites) {
    final String q = _query.toLowerCase();
    return all.where((Template t) {
      final bool okFav = !_favoritesOnly || favorites.contains(t.id);
      final bool okCat = _category == null || t.category == _category;
      final bool okQuery = q.isEmpty || t.title.toLowerCase().contains(q);
      return okFav && okCat && okQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Template>> templates = ref.watch(templatesProvider);
    final Set<String> favorites = ref.watch(favoritesProvider);

    return MorfoScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(templatesProvider);
          await ref.read(templatesProvider.future);
        },
        color: MorfoColors.holoViolet,
        backgroundColor: MorfoColors.surface2,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
          const SliverToBoxAdapter(child: _CustomPromptCard()),
          SliverToBoxAdapter(
            child: _CategoryBar(
              selected: _category,
              favoritesOnly: _favoritesOnly,
              onSelected: (MorfoCategory? c) => setState(() {
                _category = c;
                _favoritesOnly = false;
              }),
              onFavoritesTap: () => setState(() {
                _favoritesOnly = !_favoritesOnly;
                _category = null;
              }),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.lg)),
          ...templates.when(
            data: (List<Template> all) => _content(all, favorites),
            loading: () => const <Widget>[_LoadingSlivers()],
            error: (Object e, StackTrace _) => <Widget>[
              _ErrorSliver(onRetry: () => ref.invalidate(templatesProvider)),
            ],
          ),
          const SliverToBoxAdapter(child: SizedBox(height: Gap.giant)),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(List<Template> all, Set<String> favorites) {
    final List<Template> filtered = _filter(all, favorites);
    final Template? hero =
        _isFront ? all.where((Template t) => t.hero).firstOrNull : null;
    final List<Template> grid = hero == null
        ? filtered
        : filtered.where((Template t) => !t.hero).toList();

    if (filtered.isEmpty) {
      return <Widget>[_EmptySliver(favoritesEmpty: _favoritesOnly)];
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
          const MorfoMascot(size: 34),
          Gap.w8,
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
            tooltip: S.history,
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined, color: MorfoColors.ink),
            tooltip: S.settings,
          ),
        ],
      ),
    );
  }
}

class _CustomPromptCard extends StatelessWidget {
  const _CustomPromptCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.sm, Gap.xl, Gap.md),
      child: Pressable(
        onTap: () => context.push('/custom'),
        child: Container(
          padding: const EdgeInsets.all(Gap.lg),
          decoration: BoxDecoration(
            borderRadius: Radii.brLg,
            border: Border.all(
                color: MorfoColors.holoViolet.withValues(alpha: 0.5)),
            gradient: LinearGradient(
              colors: <Color>[
                MorfoColors.holoViolet.withValues(alpha: 0.14),
                MorfoColors.holoCyan.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: MorfoColors.holoGradient,
                ),
                child: const Icon(Icons.edit_outlined,
                    size: 22, color: MorfoColors.voidColor),
              ),
              Gap.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(S.customPrompt, style: MorfoType.titleSmall),
                    const SizedBox(height: 2),
                    Text(S.customPromptSub, style: MorfoType.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: MorfoColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    final bool has = v.isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
    widget.onChanged(v);
  }

  void _clear() {
    _controller.clear();
    setState(() => _hasText = false);
    widget.onChanged('');
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      style: MorfoType.bodyLarge,
      cursorColor: MorfoColors.holoViolet,
      decoration: InputDecoration(
        hintText: S.searchHint,
        hintStyle: MorfoType.bodyLarge.copyWith(color: MorfoColors.muted),
        prefixIcon: const Icon(Icons.search, color: MorfoColors.muted),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.close, size: 20, color: MorfoColors.muted),
                onPressed: _clear,
                tooltip: S.clear,
              )
            : null,
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
  const _CategoryBar({
    required this.selected,
    required this.onSelected,
    required this.favoritesOnly,
    required this.onFavoritesTap,
  });
  final MorfoCategory? selected;
  final ValueChanged<MorfoCategory?> onSelected;
  final bool favoritesOnly;
  final VoidCallback onFavoritesTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Gap.xl),
        children: <Widget>[
          CategoryChip(
            label: S.favorites,
            selected: favoritesOnly,
            onTap: onFavoritesTap,
          ),
          const SizedBox(width: Gap.sm),
          CategoryChip(
            label: S.all,
            selected: selected == null && !favoritesOnly,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: Gap.sm),
          for (final MorfoCategory c in MorfoCategory.values) ...<Widget>[
            CategoryChip(
              label: S.category(c),
              selected: selected == c && !favoritesOnly,
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
      eyebrow: S.featured(S.category(template.category)),
      title: template.displayTitle,
      onTap: () => context.push('/template', extra: template),
      child: StylePreview(
        beforeAsset: beforePreview(template.id),
        afterAsset: afterPreview(template.id),
        showTags: true,
        fallback: HoloPlaceholder(
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
            StylePreview(
              beforeAsset: beforePreview(template.id),
              afterAsset: afterPreview(template.id),
              showTags: false,
              fallback: HoloPlaceholder(
                seed: template.id,
                icon: iconForTemplate(template),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(gradient: MorfoColors.scrim),
            ),
            Positioned(
              top: Gap.sm,
              right: Gap.sm,
              child: FavoriteButton(templateId: template.id, size: 18),
            ),
            Positioned(
              left: Gap.md,
              right: Gap.md,
              bottom: Gap.md,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(S.category(template.category), style: MorfoType.eyebrow),
                  const SizedBox(height: 2),
                  Text(
                    template.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MorfoType.titleSmall,
                  ),
                ],
              ),
            ),
            Positioned(top: Gap.sm, left: Gap.sm, child: _CostTag(template: template)),
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
            template.isVideo ? S.video : '${template.creditCost}',
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
  const _EmptySliver({this.favoritesEmpty = false});
  final bool favoritesEmpty;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.giant, Gap.xl, 0),
        child: Column(
          children: <Widget>[
            Icon(
              favoritesEmpty ? Icons.favorite_border : Icons.search_off,
              size: 40,
              color: MorfoColors.muted,
            ),
            Gap.h12,
            Text(
              favoritesEmpty
                  ? S.favoritesEmptyHint
                  : S.noStyleMatch,
              style: MorfoType.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorSliver extends StatelessWidget {
  const _ErrorSliver({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.giant, Gap.xl, 0),
        child: Column(
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 40, color: MorfoColors.muted),
            Gap.h12,
            Text(S.loadStylesError, style: MorfoType.bodyMedium),
            Gap.h16,
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(S.retry),
              style: OutlinedButton.styleFrom(
                foregroundColor: MorfoColors.ink,
                side: const BorderSide(color: MorfoColors.stroke),
                shape: const RoundedRectangleBorder(borderRadius: Radii.brMd),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
