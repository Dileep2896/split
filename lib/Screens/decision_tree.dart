import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:split/Screens/Main/bottom_navigation_bar.dart';
import 'package:split/Screens/Welcome/welcome_screen.dart';

class DecisionTree extends StatelessWidget {
  const DecisionTree({super.key});

  static const String id = "decision_tree";

  @override
  Widget build(BuildContext context) {
    User? user = Provider.of<User?>(context);

    return user != null ? const BottomNavBar() : const WelcomeScreen();
  }
}
