import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:hey_smile/features/auth/presentation/providers/auth_provider.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_button.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_textfield.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen email ve şifrenizi girin!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();

    try {
      final result = await authProvider.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      log("Login successful: $result");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Giriş başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home');
      }
    } catch (e, stackTrace) {
      log("Login error: $e");
      log("Stack trace: $stackTrace");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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
            const Text(
              "Welcome!",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            MyTextfield(
              labelText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            MyTextfield(
              labelText: 'Password',
              controller: _passwordController,
              isObscureText: true,
            ),
            const SizedBox(height: 20),
            authProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : MyButton(title: 'LOG IN', onPressed: _handleLogin),
          ],
        ),
      ),
    );
  }
}
