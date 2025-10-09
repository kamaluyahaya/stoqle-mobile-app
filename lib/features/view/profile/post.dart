import 'package:flutter/material.dart';
import 'package:stoqle/features/view/profile/productModel.dart';

/// Posts Tab (separate class)
class PostsTab extends StatelessWidget {
  final List<ProductSample>? items;
  const PostsTab({Key? key, this.items}) : super(key: key);

  List<ProductSample> _default() {
    return List.generate(
      10,
      (i) => ProductSample(
        id: 'post-$i',
        imageUrl: 'https://picsum.photos/seed/post_$i/400/400',
        name: 'Post ${i + 1}',
        price: (800 + i * 200).toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = items == null || items!.isEmpty ? _default() : items!;
    return GridView.builder(
      key: const PageStorageKey('posts-grid'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) => ProductCard(product: list[i]),
    );
  }
}
