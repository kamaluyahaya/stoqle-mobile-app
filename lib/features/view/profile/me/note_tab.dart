import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onyxsio_grid_view/onyxsio_grid_view.dart';
import 'package:stoqle/component/loader/custom_loader.dart';
import 'package:stoqle/features/auth/models/socialPost.dart';
import 'package:stoqle/features/view/home/view_post.dart';
import 'package:stoqle/features/view/profile/me/product-card.dart';
import '../../../auth/state/note_notifier.dart';

class NotesTab extends ConsumerWidget {
  const NotesTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesNotifierProvider);

    return notesAsync.when(
      loading: () => Center(child: CustomCircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Failed to load notes: $err')),
      data: (notes) {
        debugPrint('NotesTab: notes.length = ${notes.length}');
        if (notes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: Image.asset(
                      'assets/images/notes-icon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.note_outlined,
                        size: 80,
                        color: Theme.of(
                          context,
                        ).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No notes yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your first thought — it only takes a sec.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed("/stoqle_text_posting");
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Post your first note'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return OnyxsioGridView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: notes.length,
          crossAxisCount: 4,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          staggeredTileBuilder: (index) => const OnyxsioStaggeredTile.fit(2),
          itemBuilder: (context, index) {
            final post = notes[index];
            debugPrint(
              'NotesTab: index=$index id=${post.id} text="${post.text}"',
            );

            final cover =
                (post.coverImage != null && post.coverImage!.isNotEmpty)
                ? post.coverImage!
                : (post.imageUrls.isNotEmpty ? post.imageUrls.first : '');

            return OnyxsioGridTile(
              index: index,
              heightList: const [220, 180, 250, 200],
              child: ProductContainer(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => PostViewPage(post: post)),
                ),
                id: post.id.toString(),
                name: post.authorName, // uses business_name if applicable
                img: cover, // post cover
                post_title: post.text.isNotEmpty ? post.text : 'No title',
                likes: post.likesCount.toString(),
                user_img: post.authorPic, // uses business logo or profile pic
                post_id: post.id,
                user_id: post.userId,
                updateLikeCount: (postId, isFavorited) {
                  debugPrint('like toggled for $postId -> $isFavorited');
                  // call your like API / state update here
                },
              ),
            );
          },
        );
      },
    );
  }
}

class NoteCard extends StatelessWidget {
  final SocialPost post;
  const NoteCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? cover =
        (post.coverImage != null && post.coverImage!.isNotEmpty)
        ? post.coverImage
        : (post.imageUrls.isNotEmpty ? post.imageUrls.first : null);

    final bool hasImage =
        cover != null && cover.isNotEmpty && post.coverType == 'image';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            AspectRatio(
              aspectRatio: 1.6,
              child: Image.network(
                cover,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image)),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              height: 120,
              width: double.infinity,
              color: Colors.grey[100],
              child: Text(
                post.text,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Text(
              post.text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundImage: post.authorPic.isNotEmpty
                      ? NetworkImage(post.authorPic)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: post.authorPic.isEmpty
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 6),
                Text(post.authorName, style: const TextStyle(fontSize: 12)),
                const Spacer(),
                Icon(
                  post.likedByMe ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: post.likedByMe ? Colors.redAccent : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text('${post.likesCount}'),
                const Spacer(),
                const Icon(Icons.comment, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('${post.commentsCount}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
