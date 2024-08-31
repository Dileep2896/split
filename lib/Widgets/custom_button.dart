import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.title,
    this.backgroundColor = kPrimaryLightColor,
    this.titleColor = Colors.white,
  });

  final Function() onPressed;
  final String title;
  final Color backgroundColor;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const BeveledRectangleBorder(),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: titleColor,
        ),
      ),
    );
  }
}
