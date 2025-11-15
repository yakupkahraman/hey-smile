import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_button.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  const SizedBox(height: 100),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'hey',
                          style: TextStyle(color: Colors.blue),
                        ),
                        TextSpan(
                          text: 'SMILE',
                          style: TextStyle(color: ThemeConstants.primaryColor),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  MyButton(
                    title: 'SIGN UP',
                    onPressed: () => context.push('/auth/signup'),
                  ),
                  SizedBox(height: 16),
                  MyButton(
                    title: 'LOG IN',
                    onPressed: () => context.push('/auth/login'),
                  ),
                  const SizedBox(height: 46),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
