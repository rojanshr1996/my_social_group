import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tekk_gram/views/chat/user_search_list_view.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/extensions/dismiss_keyboard.dart';

class UserSearchListScreen extends HookConsumerWidget {
  const UserSearchListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final searchTerm = useState('');

    useEffect(
      () {
        controller.addListener(() {
          searchTerm.value = controller.text;
        });
        return () {};
      },
      [controller],
    );

    return RemoveFocus(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.users),
          centerTitle: false,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: Strings.enterYourSearchTermHere,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      dismissKeyboard();
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              child: UserSearchListView(searchTerm: searchTerm.value),
            ),
          ],
        ),
      ),
    );
  }
}
