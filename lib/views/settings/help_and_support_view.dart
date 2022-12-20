import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tekk_gram/utils/utilities.dart';
import 'package:tekk_gram/views/components/custom_button.dart';
import 'package:tekk_gram/views/components/remove_focus.dart';
import 'package:tekk_gram/views/constans/app_colors.dart';
import 'package:tekk_gram/views/constans/strings.dart';
import 'package:tekk_gram/views/extensions/dismiss_keyboard.dart';

class HelpAndSupport extends HookWidget {
  const HelpAndSupport({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    return SafeArea(
      child: RemoveFocus(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text(Strings.helpAndSupport),
            backgroundColor: AppColors.transparent,
          ),
          body: SizedBox(
            height: Utilities.screenHeight(context),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              FaIcon(
                                FontAwesomeIcons.headset,
                                size: 80,
                                color: AppColors.loginButtonColor,
                              ),
                              const SizedBox(height: 30),
                              Text(
                                Strings.contactUs,
                                style: Theme.of(context).textTheme.headline5?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                Strings.howCanWeHelp,
                                style: Theme.of(context).textTheme.subtitle1?.copyWith(color: AppColors.greyColor),
                              ),
                              const SizedBox(height: 30),
                            ],
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 150),
                              child: TextField(
                                controller: controller,
                                textInputAction: TextInputAction.search,
                                maxLines: null,
                                decoration: InputDecoration(
                                  labelText: Strings.enterYourQueryHere,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.loginButtonColor,
                      foregroundColor: AppColors.loginButtonTextColor,
                    ),
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        dismissKeyboard();
                        send(controller: controller);
                      }
                    },
                    child: const CustomButton(
                      title: "Save",
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> send({required TextEditingController controller}) async {
    final Email email = Email(
      body: controller.text.trim(),
      subject: "Queries from TekkGram",
      recipients: ["rojan.shr1996@gmail.com"],
    );

    try {
      await FlutterEmailSender.send(email);

      controller.clear();
    } catch (error) {
      log(error.toString());
    }
  }
}
