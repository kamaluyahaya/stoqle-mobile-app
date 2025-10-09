import 'package:flutter/material.dart';

import 'productModel.dart';

/// Products Tab (separate class)
class ProductsTab extends StatelessWidget {
  final List<ProductSample>? items;
  const ProductsTab({Key? key, this.items}) : super(key: key);

  List<ProductSample> _default() {
    return List.generate(
      12,
      (i) => ProductSample(
        id: 'prod-$i',
        imageUrl: 'https://picsum.photos/seed/prod_$i/400/400',
        name: 'Product ${i + 1}',
        price: (1200 + i * 350).toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = items == null || items!.isEmpty ? _default() : items!;
    return GridView.builder(
      key: const PageStorageKey('products-grid'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.7,
      ),
      itemCount: list.length,
      itemBuilder: (ctx, i) => ProductCard(
        product: list[i],
        onTap: () {
          // TODO: open product details
        },
      ),
    );
  }
}
