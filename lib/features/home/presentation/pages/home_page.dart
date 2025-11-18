import 'package:flutter/material.dart';
import 'package:hey_smile/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: user?.profilePhotoUrl != null
                          ? NetworkImage(user!.profilePhotoUrl!)
                          : null,
                      child: user?.profilePhotoUrl == null
                          ? Text(
                              user?.firstName[0].toUpperCase() ?? 'U',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.fullName ?? 'Kullanıcı',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
