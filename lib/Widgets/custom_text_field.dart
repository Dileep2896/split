import 'package:flutter/material.dart';
import 'package:split/Model/constants.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.onChanged,
    this.hintText,
    this.errorBorder,
    this.enabledBorder = const UnderlineInputBorder(
      borderSide: BorderSide(color: kSecondaryColor),
    ),
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.keyBoardType,
    this.errorText,
    this.controller,
    this.icon,
    this.textAlign = TextAlign.start,
    this.textStyle = kDefaultTextStyle,
  });

  final Function(String)? onChanged;
  final String? hintText;
  final InputBorder? errorBorder;
  final bool obscureText;
  final IconButton? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyBoardType;
  final String? errorText;
  final TextEditingController? controller;
  final Widget? icon;
  final TextStyle textStyle;
  final TextAlign textAlign;
  final InputBorder enabledBorder;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      style: textStyle,
      cursorColor: kTextColor,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyBoardType,
      textAlign: textAlign,
      decoration: InputDecoration(
        icon: icon,
        errorText: errorText,
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white24,
        ),
        enabledBorder: enabledBorder,
        errorBorder: errorBorder,
        filled: true,
        fillColor: kSecondaryColor,
      ),
    );
  }
}
