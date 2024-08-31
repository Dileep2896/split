import 'package:flutter/material.dart';

class MemberSettingTrailingText extends StatelessWidget {
  const MemberSettingTrailingText({
    super.key,
    required this.text,
    required this.color,
    required this.tranDirection,
  });

  final String text;
  final String tranDirection;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          tranDirection,
          style: TextStyle(
            color: color,
          ),
        ),
        Text(
          "\$$text",
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
