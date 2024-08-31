import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';
import 'package:split/Widgets/custom_text_field.dart';

class CustomIconTextField extends StatelessWidget {
  const CustomIconTextField({
    super.key,
    this.onChanged,
    required this.icon,
    this.hint,
    this.keyBoardType,
    this.controller,
    this.validator,
  });

  final Function(String?)? onChanged;
  final String? Function(String?)? validator;
  final IconData icon;
  final String? hint;
  final TextInputType? keyBoardType;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: kPrimaryLightColor,
            border: Border.all(color: Colors.white38, width: 2),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: CustomTextField(
            controller: controller,
            hintText: hint,
            keyBoardType: keyBoardType,
            onChanged: onChanged,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
