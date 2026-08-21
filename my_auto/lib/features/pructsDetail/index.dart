import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:my_auto/core/provider/auth/auth.dart';
import 'package:my_auto/core/provider/home/getProductById/index.dart';
import 'package:my_auto/core/provider/home/getProductOfCategories/index.dart';
import 'package:my_auto/features/advertisement/domain/advertisement.dart';
import 'package:my_auto/features/advertisement/presentation/ad_banner.dart';
import 'package:my_auto/features/discovery/presentation/providers/discovery_provider.dart';
import 'package:my_auto/features/discovery/presentation/widgets/product_carousel_section.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/core/layout/app_safe_area.dart';
import 'package:my_auto/core/theme/colors/index.dart';
import 'package:my_auto/core/theme/tokens.dart';
import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/errors/graphql_error_ui.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/features/chat/chat_di.dart';
import 'package:my_auto/features/chat/domain/failures/chat_failure.dart';
import 'package:my_auto/generated/l10n.dart';
import 'package:provider/provider.dart';
import 'package:my_auto/features/pructsDetail/widgets/OtherListingsBySeller/index.dart';
import 'package:my_auto/features/pructsDetail/widgets/RelatedProductsSection/index.dart';
import 'package:my_auto/features/pructsDetail/widgets/descriptionSection/index.dart';
import 'package:my_auto/features/pructsDetail/widgets/productInfo/index.dart';
import 'package:my_auto/features/pructsDetail/widgets/productTitle/index.dart';
import 'package:my_auto/features/pructsDetail/widgets/sellerInfo/index.dart';
import 'package:my_auto/core/model/product/index.dart';
import 'package:my_auto/features/promotion/presentation/promote_product_sheet.dart';
import 'package:my_auto/features/pructsDetail/widgets/slider/index.dart';
import 'package:url_launcher/url_launcher.dart';

class ProductDetailScreen extends StatefulWidget {
  final String id;
  const ProductDetailScreen({super.key, required this.id});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final GetProductById provider;
  final ScrollController _sellerScrollController = ScrollController();
  bool _sellerScrollListenerAttached = false;

  @override
  void initState() {
    super.initState();
    provider = GetProductById();
    provider.loadProductById(widget.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DiscoveryProvider>().loadSimilar(widget.id);
      final productsProvider = context.read<ProductProvider>();

      provider.addListener(() {
        final product = provider.product;
        if (product == null || product.seller == null) return;

        final sellerFilters = {"seller": product.seller!.id};
        final categoryFilters = {"category": product.category!.id};

        if (productsProvider.getProducts(sellerFilters).isEmpty &&
            !productsProvider.isMoreLoadingFor(sellerFilters)) {
          productsProvider.loadList(filters: sellerFilters, reset: true);
        }

        if (productsProvider.getProducts(categoryFilters).isEmpty &&
            !productsProvider.isMoreLoadingFor(categoryFilters)) {
          productsProvider.loadList(filters: categoryFilters, reset: true);
        }

        if (!_sellerScrollListenerAttached) {
          _sellerScrollListenerAttached = true;
          _sellerScrollController.addListener(() {
            if (_sellerScrollController.position.pixels >=
                    _sellerScrollController.position.maxScrollExtent - 100 &&
                !productsProvider.isMoreLoadingFor(sellerFilters) &&
                productsProvider.hasMoreFor(sellerFilters)) {
              productsProvider.loadMore(filters: sellerFilters);
            }
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GetProductById>.value(
      value: provider,
      child: _ProductDetailView(
        id: widget.id,
        sellerScrollController: _sellerScrollController,
      ),
    );
  }

  @override
  void dispose() {
    _sellerScrollController.dispose();
    provider.dispose();
    super.dispose();
  }
}

class _ProductDetailView extends StatelessWidget {
  final String id;
  final ScrollController sellerScrollController;

  const _ProductDetailView({
    required this.id,
    required this.sellerScrollController,
  });

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    final providerById = context.watch<GetProductById>();
    final product = providerById.product;

    if (providerById.isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: colors.textPrimary),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.alertCircle,
                    size: 48, color: colors.textMuted),
                const SizedBox(height: 12),
                Text(
                  GraphqlErrorUi.localizeRaw(
                    context,
                    providerById.errorMessage,
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () =>
                      context.read<GetProductById>().loadProductById(id),
                  child: Text(s.update),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final productsProvider = context.watch<ProductProvider>();
    final sellerFilters = {"seller": product.seller!.id};
    final categoryFilters = {"category": product.category!.id};

    final sellerProducts = productsProvider
        .getProducts(sellerFilters)
        .where((p) => p.id != product.id)
        .toList();

    final hasMore = productsProvider.hasMoreFor(sellerFilters);
    final isMoreLoading = productsProvider.isMoreLoadingFor(sellerFilters);

    final relatedProducts = productsProvider
        .getProducts(categoryFilters)
        .where((p) => p.id != product.id)
        .toList();

    final discovery = context.watch<DiscoveryProvider>();
    final similarProducts = discovery
        .feed(DiscoveryFeed.similar)
        .where((p) => p.id != product.id)
        .toList();

    final itemWidth = MediaQuery.of(context).size.width * 0.45;
    final myId = context.read<AuthProvider>().auth?.user.id;
    final isOwnProduct = myId != null &&
        myId.isNotEmpty &&
        product.seller?.id == myId;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProductImagesSlider(
              images: product.images,
              partId: product.id,
              initialIsFavorite: product.isFavorite,
            ),
          ),
          ProductTitle(
            name: product.name,
            price: product.price,
            currency: product.currency,
            category: product.category!,
            createdDate: product.createdAt,
          ),
          ProductInfo(
            condition: product.condition ?? false,
            delivery: product.delivery,
            negotiable: product.negotiable ?? false,
          ),
          DescriptionSectionPart(
            description: product.description,
            sellerPhone: product.seller!.phone,
          ),
          const SliverToBoxAdapter(
            child: AdBanner(
              surface: AdSurface.part,
              height: 130,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          SellerInfo(
            sellerId: product.seller!.id,
            sellerName: product.seller!.name,
            createdAt: product.seller!.createdAt,
            sellerImage: product.seller!.image,
          ),
          OtherListingsBySeller(
            products: sellerProducts,
            scrollController: sellerScrollController,
            hasMore: hasMore,
            isMoreLoading: isMoreLoading,
            itemWidth: itemWidth,
          ),
          if (similarProducts.isNotEmpty ||
              discovery.isLoading(DiscoveryFeed.similar))
            SliverToBoxAdapter(
              child: ProductCarouselSection(
                title: s.similarProducts,
                subtitle: s.recommendedForYouSubtitle,
                icon: LucideIcons.layers,
                products: similarProducts,
                isLoading: discovery.isLoading(DiscoveryFeed.similar),
              ),
            ),
          RelatedProductsSection(
            relatedProducts: relatedProducts,
            itemWidth: itemWidth,
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: bottomSafeOffset(context, 88)),
          ),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        phone: product.seller!.phone,
        sellerId: product.seller!.id,
        sellerName: product.seller!.name,
        partId: product.id,
        product: product,
        isOwner: isOwnProduct,
        onCall: () => _call(product.seller!.phone),
        onPromote: () async {
          final promoted = await showPromoteProductSheet(
            context,
            product: product,
          );
          if (promoted == true && context.mounted) {
            await context.read<GetProductById>().loadProductById(product.id);
          }
        },
      ),
    );
  }
}

class _BottomActionBar extends StatefulWidget {
  const _BottomActionBar({
    required this.phone,
    required this.sellerId,
    required this.sellerName,
    required this.partId,
    required this.product,
    required this.onCall,
    required this.onPromote,
    this.isOwner = false,
  });

  final String phone;
  final String sellerId;
  final String sellerName;
  final String partId;
  final Part product;
  final VoidCallback onCall;
  final VoidCallback onPromote;
  final bool isOwner;

  @override
  State<_BottomActionBar> createState() => _BottomActionBarState();
}

class _BottomActionBarState extends State<_BottomActionBar> {
  bool _openingChat = false;

  Future<void> _writeSeller() async {
    if (_openingChat) return;

    final authed = await AuthGuard.requireAuth(
      context,
      pending: PendingWriteSeller(
        recipientId: widget.sellerId,
        partId: widget.partId,
        sellerName: widget.sellerName,
      ),
      message: 'Sign in to message this seller',
    );
    if (!authed || !mounted) return;

    final auth = context.read<AuthProvider>().auth!;
    if (auth.user.id == widget.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorCannotMessageSelf)),
      );
      return;
    }
    if (widget.sellerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).errorSellerUnavailable)),
      );
      return;
    }
    setState(() => _openingChat = true);
    try {
      final conversation = await chatRepository.createConversation(
        recipientId: widget.sellerId,
        partId: widget.partId,
      );
      if (!mounted) return;
      context.push(
        '${RoutesName.chatDetail}/${conversation.id}',
        extra: widget.sellerName,
      );
    } on ChatFailure catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final s = S.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        stickyBottomPadding(context, keyboardExtra: 0, homeExtra: 12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.rXl,
          border: Border.all(color: colors.border),
          boxShadow: AppShadows.floating(context),
        ),
        child: widget.isOwner
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onPromote,
                  icon: Icon(
                    widget.product.isPromotionActive
                        ? LucideIcons.sparkles
                        : LucideIcons.trendingUp,
                    size: 18,
                  ),
                  label: Text(
                    widget.product.isPromotionActive
                        ? '${s.promotedTop} · plan'
                        : 'Choose promotion plan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openingChat ? null : _writeSeller,
                      icon: _openingChat
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.primary,
                              ),
                            )
                          : const Icon(LucideIcons.messageSquare, size: 18),
                      label: Text(
                        s.writeSeller,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(color: colors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: widget.onCall,
                      icon: const Icon(LucideIcons.phone, size: 18),
                      label: Text(
                        s.callSeller,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
