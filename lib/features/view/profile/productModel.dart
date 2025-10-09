import 'package:flutter/material.dart';

import '../../../component/colors/color.dart';

/// Simple model used by tabs
class ProductSample {
  final String id;
  final String imageUrl;
  final String name;
  final double price;

  ProductSample({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.price,
  });
}

/// Reusable Apple-like ProductCard
class ProductCard extends StatelessWidget {
  final ProductSample product;
  final VoidCallback? onTap;

  const ProductCard({Key? key, required this.product, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Hero(
                  tag: 'prod-${product.id}',
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) =>
                              progress == null
                              ? child
                              : const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(Icons.broken_image),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image),
                        ),
                ),
              ),
            ),

            // details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: "Bold", fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₦${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontFamily: "Bold",
                          fontSize: 13,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Small widget reused for the three action boxes.
class profileOrderContainer extends StatelessWidget {
  final icon, title, subtitle;
  const profileOrderContainer({
    super.key,
    this.icon,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // removed Expanded here — parent decides available width (we use Flexible there)
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Color.fromARGB(17, 255, 255, 255),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 15),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: "Bold",
                  ),
                ),
                Text(
                  "$subtitle",
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.textColor2,
                    fontFamily: "Regular",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
