import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Widgets/custom_button.dart';

class DialogUtils {
  static final DialogUtils _instance = DialogUtils.internal();

  DialogUtils.internal();

  factory DialogUtils() => _instance;

  static void showCustomDialog(
    BuildContext context, {
    required title,
    okBtnText = "Settle",
    cancelBtnText = "Cancel",
    isShowCancel = true,
    required Function(BuildContext context) okBtnFunction,
    required Widget content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          backgroundColor: kSecondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          actions: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  // Try using Expanded inside a ButtonBar
                  child: CustomButton(
                    onPressed: () => okBtnFunction(context),
                    title: okBtnText,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                isShowCancel
                    ? CustomButton(
                        title: cancelBtnText,
                        onPressed: () => Navigator.pop(context),
                        backgroundColor: Colors.black45,
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        );
      },
    );
  }
}
