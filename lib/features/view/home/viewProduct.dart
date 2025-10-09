import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stoqle/component/colors/color.dart';

import '../../../core/widget/bottom-cart.dart';
import '../../auth/models/socialPost.dart';
import '../market/widget/product/product-description.dart';
import 'view_post.dart';

class ViewUserPost extends StatefulWidget {
  final SocialPost product; // list of image URLs
  const ViewUserPost(this.product, {Key? key}) : super(key: key);

  @override
  State<ViewUserPost> createState() => _ViewUserPostState();
}

class _ViewUserPostState extends State<ViewUserPost> {
  late PageController _pageController;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    final product = widget.product;
    final images = (product.imageUrls != null && product.imageUrls.isNotEmpty)
        ? product.imageUrls
        : (product.coverImage != null && product.coverImage!.isNotEmpty
              ? [product.coverImage!]
              : []);

    if (images.isNotEmpty) {
      // 👇 preload aspect ratio for the first image
      _resolveAspect(images[0]);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildDot(bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: active ? 18 : 6,
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  double? _currentAspect;

  void _resolveAspect(String url) {
    final image = Image.network(url);
    image.image
        .resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((info, _) {
            final aspect = info.image.width / info.image.height;
            if (mounted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() => _currentAspect = aspect);
              });
            }
          }),
        );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = (product.imageUrls != null && product.imageUrls.isNotEmpty)
        ? product.imageUrls
        : (product.coverImage != null && product.coverImage!.isNotEmpty
              ? [product.coverImage!]
              : []);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: kWhiteSmoke,
        body: SafeArea(
          top: false,
          child: Column(
            // This is the main column
            children: [
              Expanded(
                // The Expanded widget makes this section fill the available space
                child: SingleChildScrollView(
                  // This makes the content inside it scrollable
                  child: Column(
                    // The content that will scroll
                    children: [
                      AspectRatio(
                        aspectRatio: _currentAspect ?? 1,
                        child: Stack(
                          children: [
                            if (images.isEmpty)
                              const Center(child: Icon(Icons.image, size: 48))
                            else
                              PageView.builder(
                                controller: _pageController,
                                itemCount: images.length,
                                onPageChanged: (i) {
                                  setState(() => _pageIndex = i);
                                },
                                itemBuilder: (context, index) {
                                  final url = images[index];
                                  return InteractiveViewer(
                                    minScale: 1,
                                    maxScale: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                PhotoViewGalleryPage(
                                                  images: images.cast<String>(),
                                                  initialIndex: index,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Hero(
                                        tag: url,
                                        child: CachedNetworkImage(
                                          imageUrl: url,
                                          fit: BoxFit.contain,
                                          width: double.infinity,
                                          height: double.infinity,
                                          placeholder: (context, _) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          errorWidget: (context, _, __) =>
                                              const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 42,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(70, 78, 77, 77),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_pageIndex + 1}/${images.length}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(70, 78, 77, 77),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${_pageIndex + 1}/${images.length}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (images.length > 1)
                        Container(
                          height: 60,
                          decoration: BoxDecoration(color: kWhiteSmoke),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              itemCount: images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 0),
                              itemBuilder: (context, index) {
                                final url = images[index];
                                final isSelected = index == _pageIndex;
                                return GestureDetector(
                                  onTap: () {
                                    _pageController.jumpToPage(index);
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: url,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.contain,
                                        ),
                                        if (isSelected)
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.black26,
                                              border: Border.all(
                                                width: 1.5,
                                                color: AppColors.kDefault,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ProductDescription(product),

                      ProductInfoSection(),
                      SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Business Logo + Info
                            Expanded(
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 35,
                                    backgroundImage: NetworkImage(
                                      widget.product.authorPic, // business logo
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  const SizedBox(width: 12),

                                  // Business Info (Name + Ratings + Followers + Items Sold)
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Business Name
                                        Text(
                                          widget.product.authorName,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontFamily: "Bold",
                                            color: AppColors.kDarkMode,
                                          ),
                                          maxLines: 1, // 👈 prevents overflow
                                          overflow: TextOverflow
                                              .ellipsis, // 👈 adds "..."
                                        ),
                                        const SizedBox(height: 4),

                                        // Ratings row
                                        Container(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Color.fromARGB(
                                                    255,
                                                    15,
                                                    107,
                                                    98,
                                                  ), // teal background
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  "Central Market",
                                                  style: TextStyle(
                                                    color: Colors
                                                        .white, // white text
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                                  const Icon(
                                                    Icons.star,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                                  const Icon(
                                                    Icons.star_half,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                                  const Icon(
                                                    Icons.star_border,
                                                    color: Colors.orange,
                                                    size: 16,
                                                  ),
                                                ],
                                              ),

                                              const SizedBox(width: 6),
                                              const Text(
                                                "4.2k",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Followers and items sold
                                        const Text(
                                          "12k Followers • 5.8k Items Sold",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Visit Shop Button
                            Container(
                              height: 35,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Navigate to shop page
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.kDefault,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Text(
                                  "Visit Shop",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "Bold",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // SizedBox(height: 5),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "- Product Details -",
                            style: TextStyle(color: kWhite40),
                          ),
                        ),
                      ),
                      // ... your other scrollable content here
                      ...images.map(
                        (url) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CachedNetworkImage(
                            imageUrl: url,
                            width: double.infinity,
                            // height: 300, // 👈 give it a height
                            fit: BoxFit.cover, // full-width big image
                            placeholder: (context, _) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, _, __) => const Center(
                              child: Icon(Icons.broken_image, size: 42),
                            ),
                          ),
                        ),
                      ),

                      // SizedBox(height: 10),
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "- You may also like -",
                            style: TextStyle(color: kWhite40),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // This BottomCart widget remains fixed at the bottom
              BottomCart(widget.product.authorPic),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductInfoSection extends StatelessWidget {
  const ProductInfoSection({super.key});

  void _showDetails(
    BuildContext context,
    String header, // 👈 new header parameter
    String title,
    String details,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kWhiteSmoke,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        return SizedBox(
          height: screenHeight * 0.75, // 👈 fixed 75% height
          child: Column(
            children: [
              // HEADER with close icon
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 5,
                  ),
                  child: Row(
                    children: [
                      // Invisible placeholder for symmetry
                      const SizedBox(
                        width: 48,
                      ), // same width as the close button
                      // Centered header
                      Expanded(
                        child: Text(
                          header,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Close button at right
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 5),
              // BODY
              Expanded(
                child: Container(
                  color: kWhite,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kWhite40,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Scrollable details
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              details,
                              style: TextStyle(
                                fontSize: 15,
                                color: kWhite40,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    IconData icon,
    String text,
    String details, {
    required String header,
  }) {
    return InkWell(
      onTap: () => _showDetails(context, header, text, details),
      child: ListTile(
        dense: true, // 👈 makes row height smaller
        visualDensity: const VisualDensity(
          horizontal: -2,
          vertical: -2,
        ), // 👈 reduce padding
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
        ), // 👈 tighter left/right
        leading: Icon(icon, color: kWhite20, size: 20),
        title: Text(
          text,
          style: TextStyle(color: kWhite20, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: Column(
        children: [
          _buildTile(
            context,
            Icons.local_shipping,
            "Ships within 8 hours on average | Promised to ship within 48 hours",
            "Seller guarantees dispatch within 24 hours. If delayed, compensation is provided.",
            header: "Shipping Information",
          ),
          _buildTile(
            context,
            Icons.assignment_return,
            "Return shipping subsidy | 7-day no reason return",
            "You may return within 7 days for any reason. Return shipping subsidy applies.",
            header: "Service Information",
          ),
          _buildTile(
            context,
            Icons.check_circle,
            "Selected: M",
            "You have selected size M. You may change this in product options.",
            header: "Specification Selection",
          ),
        ],
      ),
    );
  }
}
