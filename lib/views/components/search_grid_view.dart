import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/state/posts/providers/posts_by_search_term_provider.dart';
import 'package:tekk_gram/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:tekk_gram/views/components/animations/empty_search_animation_view.dart';
import 'package:tekk_gram/views/components/animations/error_animation_view.dart';
import 'package:tekk_gram/views/components/post/post_sliver_grid_view.dart';
import 'package:tekk_gram/views/constans/strings.dart';

class SearchGridView extends ConsumerWidget {
  final String searchTerm;

  const SearchGridView({
    super.key,
    required this.searchTerm,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchTerm.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyContentsWithTextAnimationView(text: Strings.enterYourSearchTerm),
      );
    }

    final posts = ref.watch(
      postsBySearchTermProvider(searchTerm),
    );

    return posts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptySearchAnimationView(),
          );
        } else {
          return PostsSliverGridView(posts: posts);
        }
      },
      error: (error, stackTrace) {
        return const SliverToBoxAdapter(
          child: ErrorAnimationView(),
        );
      },
      loading: () {
        return const SliverToBoxAdapter(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
