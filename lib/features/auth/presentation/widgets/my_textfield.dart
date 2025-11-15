import 'package:flutter/material.dart';
import 'package:hey_smile/core/constants.dart';

class MyTextfield extends StatelessWidget {
  const MyTextfield({
    super.key,
    required this.labelText,
    this.isObscureText = false,
    this.suffixIcon,
    this.showSuffixIcon,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  final String labelText;
  final bool isObscureText;
  final Widget? suffixIcon;
  final bool? showSuffixIcon;
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        obscureText: isObscureText,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: ThemeConstants.primaryColor,
              width: 2.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 18.0,
          ),
          isDense: true,
          suffixIcon: showSuffixIcon == true ? suffixIcon : null,
        ),
        style: TextStyle(fontFamily: 'Poppins', fontSize: 16),
        keyboardType: keyboardType,
      ),
    );
  }
}
