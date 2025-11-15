import 'package:flutter/material.dart';
import 'package:hey_smile/core/constants.dart';

class MyButton extends StatelessWidget {
  const MyButton({super.key, required this.title, this.onPressed});

  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.secondaryColor,
          overlayColor: ThemeConstants.primaryColor,
          shadowColor: ThemeConstants.primaryColor,
          surfaceTintColor: ThemeConstants.primaryColor,

          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
