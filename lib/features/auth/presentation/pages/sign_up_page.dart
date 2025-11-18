import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hey_smile/core/constants.dart';
import 'package:hey_smile/features/auth/data/auth_service.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_button.dart';
import 'package:hey_smile/features/auth/presentation/widgets/my_textfield.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dateOfBirthController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirthController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _handleSignUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler eşleşmiyor!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _dateOfBirthController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        dateOfBirth: _dateOfBirthController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Kayıt başarılı!'),
            backgroundColor: Colors.green,
          ),
        );
        // Login sayfasına yönlendir
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Let's Sign Up!",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: MyTextfield(
                        labelText: 'Ad',
                        controller: _firstNameController,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyTextfield(
                        labelText: 'Soyad',
                        controller: _lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  labelText: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  labelText: 'Telefon',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: MyTextfield(
                      labelText: 'Doğum Tarihi (YYYY-MM-DD)',
                      controller: _dateOfBirthController,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  labelText: 'Şifre',
                  controller: _passwordController,
                  isObscureText: true,
                ),
                const SizedBox(height: 10),
                MyTextfield(
                  labelText: 'Şifre Tekrar',
                  controller: _confirmPasswordController,
                  isObscureText: true,
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : MyButton(title: 'SIGN UP', onPressed: _handleSignUp),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
