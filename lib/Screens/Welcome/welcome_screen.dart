import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Screens/Welcome/login_screen.dart';
import 'package:split/Screens/Welcome/registration_screen.dart';
import 'package:split/Widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const String id = "welcome_screen";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 60,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "WELCOME TO SPLIT",
                textAlign: TextAlign.center,
                style: kTitleTextStyle,
              ),
              kWidgetHeightGap,
              CustomButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegistrationScreen.id);
                },
                title: "REGISTER",
              ),
              Row(
                children: [
                  const Text(
                    "Already a user?",
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.id);
                    },
                    style: TextButton.styleFrom(
                      overlayColor: const Color(0x00000000),
                    ),
                    child: const Text(
                      "Log in",
                      style: kDefaultTextStyle,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
