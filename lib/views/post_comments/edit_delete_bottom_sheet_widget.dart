import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';

class EditDeleteBottomPopup extends StatelessWidget {
  final Function(int)? onSelected;
  const EditDeleteBottomPopup({super.key, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 1,
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.pencil,
                  color: AppColors.loginButtonColor,
                  size: 18,
                ),
                const SizedBox(width: 12),
                const Text("Edit")
              ],
            ),
          ),
          PopupMenuItem(
            value: 2,
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.trash,
                  color: AppColors.loginButtonColor,
                  size: 18,
                ),
                const SizedBox(width: 12),
                const Text("Delete")
              ],
            ),
          ),
        ],
        offset: const Offset(0, 60),
        color: Theme.of(context).primaryColor,
        elevation: 2,
        onSelected: (value) {
          if (onSelected != null) {
            onSelected!(value);
          }
        },
        child: Container(
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.more_vert,
          ),
        ),
      ),
    );
  }
}
