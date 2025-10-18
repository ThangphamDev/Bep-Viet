import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'presentation/routes/app_router.dart';
import 'presentation/widgets/main_navigation.dart';

void main() {
  runApp(const BepVietApp());
}

class BepVietApp extends StatelessWidget {
  const BepVietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
