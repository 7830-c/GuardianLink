import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
