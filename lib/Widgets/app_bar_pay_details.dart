import 'package:flutter/material.dart';

class AppBarPayDetail extends StatelessWidget {
  const AppBarPayDetail({
    super.key,
    required this.payTitle,
    required this.payAmount,
    this.textColor = Colors.white,
    this.payAmountColor = Colors.greenAccent,
  });

  final String payTitle;
  final String payAmount;
  final Color? payAmountColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: payAmountColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              payTitle,
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
            Text(
              payAmount,
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
