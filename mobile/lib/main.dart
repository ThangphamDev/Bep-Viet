import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/config/app_config.dart';
import 'presentation/routes/app_router.dart';
import 'data/sources/remote/api_service.dart';
import 'data/sources/remote/auth_service.dart';
import 'data/sources/remote/google_auth_service.dart';
import 'data/sources/local/biometric_auth_service.dart';
import 'data/sources/remote/premium_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/premium_repository.dart';
import 'presentation/features/auth/cubit/auth_cubit.dart';
import 'presentation/features/premium/cubit/premium_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio();
  final apiService = ApiService(dio);
  final authService = AuthService(apiService, prefs);
  final googleAuthService = GoogleAuthService(dio);
  final biometricAuthService = BiometricAuthService();
  final authRepository = AuthRepository(
    authService,
    googleAuthService,
    biometricAuthService,
  );
  final premiumService = PremiumService(dio);
  final premiumRepository = PremiumRepository(premiumService);

  runApp(
    BepVietApp(
      authRepository: authRepository,
      premiumRepository: premiumRepository,
    ),
  );
}

class BepVietApp extends StatefulWidget {
  final AuthRepository authRepository;
  final PremiumRepository premiumRepository;

  const BepVietApp({
    super.key,
    required this.authRepository,
    required this.premiumRepository,
  });

  @override
  State<BepVietApp> createState() => _BepVietAppState();
}

class _BepVietAppState extends State<BepVietApp> {
  late final AuthCubit _authCubit;
  late final PremiumCubit _premiumCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(widget.authRepository);
    _premiumCubit = PremiumCubit(widget.premiumRepository);
    _router = AppRouter.router(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _premiumCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<PremiumCubit>.value(value: _premiumCubit),
      ],
      child: MaterialApp.router(
        title: AppConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
