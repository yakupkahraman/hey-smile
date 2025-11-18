import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hey_smile/core/theme/theme_provider.dart';
import 'package:hey_smile/core/router_manager.dart';
import 'package:hey_smile/features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Uygulama başladığında user bilgilerini yükle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUserFromPrefs();
    });
  }

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
