enum LottieAnimation {
  dataNotFound(name: 'data_not_found'),
  empty(name: 'empty'),
  loading(name: 'loading'),
  error(name: 'error'),
  smallError(name: 'small_error'),
  emptySearch(name: 'empty_search'),
  emptyPosts(name: 'empty_posts');

  final String name;
  const LottieAnimation({
    required this.name,
  });
}
