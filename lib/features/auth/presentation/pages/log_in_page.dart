import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_button.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_textfield.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: context.pop,
          icon: PhosphorIcon(
            PhosphorIcons.caretLeft(),
            color: ThemeConstants.primaryColor,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome!",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            MyTextfield(labelText: 'Email'),
            const SizedBox(height: 16),
            MyTextfield(labelText: 'Password', isObscureText: true),
            const SizedBox(height: 20),
            MyButton(title: 'LOG IN', onPressed: () => context.go('/home')),
          ],
        ),
      ),
    );
  }
}
