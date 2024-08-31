import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';

void showToast(BuildContext context, String message,
    {Duration duration = const Duration(milliseconds: 500)}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      content: Text(
        message,
        style: kDefaultTextStyle,
      ),
      backgroundColor: kSecondaryColor,
    ),
  );
}
