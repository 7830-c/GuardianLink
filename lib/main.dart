import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase core import
import 'firebase_options.dart'; // Configuration file import
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  // 1. Flutter bindings initialize karna zaroori hai async main ke liye
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase initialize karein generated options ke saath
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // System UI setup
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0B1326),
    ),
  );

  runApp(const GuardianLinkApp());
}

class GuardianLinkApp extends StatelessWidget {
  const GuardianLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'GuardianLink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}