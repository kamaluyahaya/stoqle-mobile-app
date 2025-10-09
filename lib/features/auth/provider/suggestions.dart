// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:phosphor_flutter/phosphor_flutter.dart';

// // adjust these two imports to your project paths if needed
// import 'package:stoqle/component/colors/color.dart';
// import 'package:stoqle/features/auth/models/suggestion_param.dart';

// import '../../view/profile/profileData.dart';
// import '../state/suggestion_notifier.dart';
// import 'suggestion_provider.dart';

// /// A self-contained suggestions section that shows "You may be interested in"
// /// with horizontal chips and per-button follow loading.
// class SuggestionsSection extends ConsumerWidget {
//   const SuggestionsSection({Key? key}) : super(key: key);

//   static const _params = SuggestionParams(limit: 8, offset: 0, q: '');

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // watch the notifier state for these params
//     final suggestionsState = ref.watch(suggestionNotifierProvider(_params));
//     // per-button loading set
//     final loadingSet = ref.watch(followLoadingProvider);

//     return DelayedSlideIn(
//       delay: const Duration(seconds: 6),
//       duration: const Duration(milliseconds: 380),
//       builder: (hide) {
//         return ProfileOrderContainer(
//           title: 'You may be interested in',
//           subtitle: suggestionsState.when(
//             data: (users) {
//               if (users.isEmpty) {
//                 return const Text(
//                   'No suggestions yet.',
//                   style: TextStyle(color: Colors.white70),
//                 );
//               }

//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: users.map((u) {
//                     final isLoading = loadingSet.contains(u.userId);

//                     return Container(
//                       margin: const EdgeInsets.only(right: 12),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           CircleAvatar(
//                             radius: 20,
//                             backgroundImage: u.profilePic.isNotEmpty
//                                 ? NetworkImage(u.profilePic)
//                                 : null,
//                             child: u.profilePic.isEmpty
//                                 ? Icon(
//                                     PhosphorIcons.cat(),
//                                     color: Colors.orange,
//                                   )
//                                 : null,
//                           ),
//                           const SizedBox(height: 10),
//                           SizedBox(
//                             width: 80,
//                             child: Text(
//                               u.fullName,
//                               style: TextStyle(
//                                 color: kWhite10,
//                                 fontFamily: 'bold',
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           SizedBox(
//                             height: 28,
//                             child: ElevatedButton(
//                               onPressed: isLoading
//                                   ? null
//                                   : () async {
//                                       // add userId to loading set
//                                       ref
//                                           .read(followLoadingProvider.notifier)
//                                           .update((s) {
//                                             final copy = Set<int>.from(s);
//                                             copy.add(u.userId);
//                                             return copy;
//                                           });

//                                       try {
//                                         // call the notifier's followUser for these params
//                                         final success = await ref
//                                             .read(
//                                               suggestionNotifierProvider(
//                                                 _params,
//                                               ).notifier,
//                                             )
//                                             .followUser(u.userId);

//                                         if (success) {
//                                           ScaffoldMessenger.of(
//                                             context,
//                                           ).showSnackBar(
//                                             const SnackBar(
//                                               content: Text('Followed'),
//                                               duration: Duration(
//                                                 milliseconds: 900,
//                                               ),
//                                             ),
//                                           );
//                                         } else {
//                                           ScaffoldMessenger.of(
//                                             context,
//                                           ).showSnackBar(
//                                             const SnackBar(
//                                               content: Text('Failed to follow'),
//                                             ),
//                                           );
//                                         }
//                                       } catch (e) {
//                                         ScaffoldMessenger.of(
//                                           context,
//                                         ).showSnackBar(
//                                           SnackBar(
//                                             content: Text(
//                                               'Error: ${e.toString()}',
//                                             ),
//                                           ),
//                                         );
//                                       } finally {
//                                         // remove userId from loading set
//                                         ref
//                                             .read(
//                                               followLoadingProvider.notifier,
//                                             )
//                                             .update((s) {
//                                               final copy = Set<int>.from(s);
//                                               copy.remove(u.userId);
//                                               return copy;
//                                             });
//                                       }
//                                     },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: AppColors.kDefault,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                 ),
//                               ),
//                               child: isLoading
//                                   ? const SizedBox(
//                                       width: 14,
//                                       height: 14,
//                                       child: CircularProgressIndicator(
//                                         strokeWidth: 2,
//                                         valueColor: AlwaysStoppedAnimation(
//                                           Colors.white,
//                                         ),
//                                       ),
//                                     )
//                                   : const Text(
//                                       'Follow',
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.white,
//                                       ),
//                                     ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               );
//             },
//             loading: () => const SizedBox(
//               height: 64,
//               child: Center(
//                 child: SizedBox(
//                   width: 18,
//                   height: 18,
//                   child: CircularProgressIndicator(strokeWidth: 2),
//                 ),
//               ),
//             ),
//             error: (err, st) => SizedBox(
//               height: 64,
//               child: Center(
//                 child: Text(
//                   'Failed to load',
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//               ),
//             ),
//           ),
//           icon: PhosphorIcons.shoppingCartSimple(),
//           onClose: hide,
//         );
//       },
//     );
//   }
// }
