import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const String userName = 'Yakup Açmacı';

  @override
  Widget build(BuildContext context) {
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
                    CircleAvatar(radius: 40, backgroundColor: Colors.white),
                    const SizedBox(height: 10),
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 20),
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
