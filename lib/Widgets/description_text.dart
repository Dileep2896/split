import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';

class DescriptionTextStyle extends StatelessWidget {
  final String text;

  const DescriptionTextStyle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    RegExp regExp = RegExp(r'\$\d+(\.\d+)?');
    Match? match = regExp.firstMatch(text);

    if (match != null) {
      String beforeAmount = text.substring(0, match.start);
      String amount = match.group(0)!;
      String afterAmount = text.substring(match.end);

      return RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
          ),
          children: <TextSpan>[
            TextSpan(text: beforeAmount),
            TextSpan(
              text: amount,
              style: const TextStyle(
                color: kTextColor,
                fontWeight: FontWeight.w900,
              ), // Customize color here
            ),
            TextSpan(text: afterAmount),
          ],
        ),
      );
    } else {
      // Return the whole text with default styling if no amount is found
      return Text(text);
    }
  }
}
