import 'package:flutter/material.dart';
import 'package:stoqle/features/view/profile/productModel.dart';

/// Notes Tab (separate class)
class NotesTab extends StatelessWidget {
  final List<ProductSample>? items;
  const NotesTab({Key? key, this.items}) : super(key: key);

  List<ProductSample> _default() {
    return List.generate(
      8,
      (i) => ProductSample(
        id: 'note-$i',
        imageUrl: 'https://picsum.photos/seed/note_$i/400/400',
        name: 'Note ${i + 1}',
        price: (500 + i * 120).toDouble(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = items == null || items!.isEmpty ? _default() : items!;
    return GridView.builder(
      key: const PageStorageKey('notes-grid'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      shrinkWrap: true,
      // primary: false,
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
