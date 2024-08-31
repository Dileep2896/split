import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';

class CustomAppbar extends StatelessWidget {
  const CustomAppbar({
    super.key,
    required this.appBar,
    required this.body,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset,
  });

  final Widget appBar;
  final Widget body;
  final FloatingActionButton? floatingActionButton;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
              ),
              color: kSecondaryColor,
              child: SafeArea(
                child: appBar,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: body,
          )
        ],
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
