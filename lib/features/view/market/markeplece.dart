import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:onyxsio_grid_view/onyxsio_grid_view.dart';
import 'package:stoqle/component/colors/color.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:stoqle/core/services/note_service.dart';
import 'package:stoqle/features/auth/models/socialPost.dart';

import '../home/viewProduct.dart';
import 'product-container-view.dart';

final notesAllNotifierProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<SocialPost>>>(
      (ref) => NotesNotifier(ref),
    );

class NotesNotifier extends StateNotifier<AsyncValue<List<SocialPost>>> {
  final Ref ref; // use Ref instead of Reader
  NotesNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      final notes = await ref.read(notesServiceProvider).fetchAll();
      state = AsyncValue.data(notes);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Pull-to-refresh method
  Future<void> refreshNotes() async {
    state = const AsyncValue.loading();
    await loadNotes();
  }
}

// MARKET VIEW (no internal RefreshIndicator; non-scrollable grid)
class MarketView extends ConsumerWidget {
  const MarketView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<double> heightOptions = [160.0, 200.0, 240.0, 280.0];
    final notesAsync = ref.watch(notesAllNotifierProvider);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        // statusBarColor: Colors.transparent, // always transparent
        statusBarIconBrightness: Brightness.light, // icons dark
      ),
      child: notesAsync.when(
        loading: () => Center(child: CustomCircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Failed to load notes: $err')),
        data: (notes) {
          // NOTE: grid is non-scrollable + shrinkWrap true so parent CustomScrollView scrolls everything.
          return OnyxsioGridView.builder(
            itemCount: notes.length + 1,
            crossAxisCount: 4,
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            staggeredTileBuilder: (index) => index == notes.length
                ? const OnyxsioStaggeredTile.fit(4)
                : const OnyxsioStaggeredTile.fit(2),
            itemBuilder: (context, index) {
              if (index == notes.length) {
                return OnyxsioGridTile(
                  index: index,
                  heightList: const [10.0],
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        "- THE END -",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }

              final post = notes[index];
              final cover =
                  (post.coverImage != null && post.coverImage!.isNotEmpty)
                  ? post.coverImage!
                  : (post.imageUrls.isNotEmpty ? post.imageUrls.first : '');

              final double tileHeight =
                  heightOptions[index % heightOptions.length];

              return OnyxsioGridTile(
                index: index,
                heightList: [tileHeight],
                child: ProductContainerView(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewUserPost(
                        post,
                        // title: post.text?.isNotEmpty == true
                        //     ? post.text
                        //     : 'No title',
                        // price: 34000,
                        // oldPrice: 22000,
                        // rating: 43,
                        // reviewsCount: 20,
                      ),
                    ),
                  ),
                  id: post.id.toString(),
                  name: post.authorName,
                  img: cover,
                  post_title: post.text.isNotEmpty ? post.text : 'No title',
                  likes: post.likesCount.toString(),
                  user_img: post.authorPic,
                  post_id: post.id,
                  user_id: post.userId,
                  updateLikeCount: (postId, isFavorited) {
                    debugPrint('like toggled for $postId -> $isFavorited');
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// MARKETPLACE - single scroll for whole page (wraps CustomScrollView with RefreshIndicator)
class MarketPlace extends ConsumerStatefulWidget {
  const MarketPlace({super.key});

  @override
  ConsumerState<MarketPlace> createState() => _MarketPlaceState();
}

class _MarketPlaceState extends ConsumerState<MarketPlace> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> categories = [
    {"name": "Fashion", "icon": LucideIcons.shoppingBag},
    {"name": "Tech", "icon": LucideIcons.smartphone},
    {"name": "Sports", "icon": LucideIcons.dumbbell},
    {"name": "Food", "icon": LucideIcons.utensils},
    {"name": "Beauty", "icon": LucideIcons.sparkles},
    {"name": "Orders", "icon": LucideIcons.package},
    {"name": "Cart", "icon": LucideIcons.shoppingCart},
    {"name": "Service", "icon": LucideIcons.headphones},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _adaptiveBg(BuildContext c) {
    final b = Theme.of(c).brightness;
    return b == Brightness.dark
        ? const Color.fromARGB(122, 158, 124, 72).withOpacity(0.03)
        : Colors.black.withOpacity(0.03);
  }

  final Set<String> attentionList = {'Orders', 'Cart', 'Service'};
  @override
  Widget build(BuildContext context) {
    final bg = _adaptiveBg(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(notesAllNotifierProvider.notifier).refreshNotes();
          },
          child: CustomScrollView(
            primary: true,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // 🔹 Fixed Header as AppBar
              SliverAppBar(
                pinned: true, // stays fixed
                floating: false,
                elevation: 0,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GradientText(
                        "Shop",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontFamily: "Bold", fontSize: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withOpacity(0.06),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  textInputAction: TextInputAction.search,
                                  decoration: const InputDecoration(
                                    hintText: 'Search...',
                                    isDense: true,
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  onSubmitted: (q) {},
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // perform search
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Search",
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Categories Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    GridView.count(
                      crossAxisCount: 4,
                      // mainAxisSpacing: 5,
                      crossAxisSpacing: 20,
                      // padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      children: categories.map((cat) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {},
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Center(
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: cat['name'] == 'Beauty'
                                        ? const [
                                            Color(0xFFf6d365),
                                            Color(0xFFfda085),
                                            Color(0xFFff9a9e),
                                          ]
                                        : const [
                                            Color(0xFFFF5F6D),
                                            Color(0xFFFFC371),
                                            AppColors.kDefault,
                                            Color(0xFF2575FC),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(bounds),
                                  child: Icon(cat['icon'], size: 22),
                                ),
                              ),

                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  cat['name'],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: "Bold",
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    // MarketView below categories
                    const MarketView(),

                    const SizedBox(height: 30),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GradientIconOnly extends StatefulWidget {
  final IconData icon;
  final double size; // icon size
  final double boxSize; // container size
  final bool animate;
  final List<Color> colors;
  final Duration duration;
  final Color backgroundColor; // the plain background behind the icon
  final double borderRadius;
  final BoxBorder? border;

  const GradientIconOnly({
    Key? key,
    required this.icon,
    this.size = 22,
    this.boxSize = 52,
    this.animate = true,
    this.colors = const [
      Color(0xFFFF5F6D),
      Color(0xFFFFC371),
      Color(0xFF6A11CB),
      Color(0xFF2575FC),
    ],
    this.duration = const Duration(milliseconds: 700),
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 12,
    this.border,
  }) : super(key: key);

  @override
  State<GradientIconOnly> createState() => _GradientIconOnlyState();
}

class _GradientIconOnlyState extends State<GradientIconOnly>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    if (widget.animate) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant GradientIconOnly old) {
    super.didUpdateWidget(old);
    if (widget.animate && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.animate && _ctrl.isAnimating) {
      _ctrl.stop();
    }
    if (old.duration != widget.duration) {
      _ctrl.duration = widget.duration;
      if (widget.animate) _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.boxSize,
      height: widget.boxSize,
      decoration: BoxDecoration(
        color: widget.backgroundColor, // plain background
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final rotation = _ctrl.value * math.pi * 2;
            return ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (rect) {
                // SweepGradient rotated by animation value.
                return SweepGradient(
                  colors: widget.colors,
                  startAngle: 0,
                  endAngle: math.pi * 2,
                  transform: GradientRotation(rotation),
                ).createShader(rect);
              },
              child: child,
            );
          },
          child: Icon(widget.icon, size: widget.size, color: Colors.white),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    Key? key,
    this.style,
    this.gradient,
    this.textAlign,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // pick a default gradient if none provided — nice for light & dark
    final defaultGradient = Theme.of(context).brightness == Brightness.dark
        ? const LinearGradient(
            colors: [Color.fromARGB(255, 255, 38, 0), Color(0xFF3A7BD5)],
          ) // cool cyan -> blue
        : const LinearGradient(
            colors: [AppColors.kDefault, Color(0xFF4A00E0)],
          ); // purple -> deep purple

    final usedGradient = gradient ?? defaultGradient;

    return ShaderMask(
      shaderCallback: (bounds) => usedGradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}
