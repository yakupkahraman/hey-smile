import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hey_smile/core/theme/theme_provider.dart';
import 'package:hey_smile/core/router_manager.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'HeySmile!',
      theme: Provider.of<ThemeProvider>(context).themeData,
      routerConfig: RouterManager.router,
    );
  }
}