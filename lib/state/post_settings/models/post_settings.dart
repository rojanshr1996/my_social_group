import 'package:tekk_gram/state/post_settings/constans/constants.dart';

enum PostSettings {
  allowLikes(
    title: Constants.allowLikesTitle,
    description: Constants.allowLikesDescription,
    storageKey: Constants.allowLikesStorageKey,
  ),

  allowComments(
    title: Constants.allowCommentsTitle,
    description: Constants.allowCommentsDescription,
    storageKey: Constants.allowCommentsStorageKey,
  );

  final String title;
  final String description;
  final String storageKey;
  const PostSettings({
    required this.title,
    required this.description,
    required this.storageKey,
  });
}
