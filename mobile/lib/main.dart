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
import 'data/repositories/auth_repository.dart';
import 'presentation/features/auth/cubit/auth_cubit.dart';
import 'presentation/features/planner/cubit/meal_plan_cubit.dart';
import 'presentation/features/shopping/cubit/shopping_list_cubit.dart';
import 'presentation/features/pantry/cubit/pantry_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final prefs = await SharedPreferences.getInstance();
  final dio = Dio();
  final apiService = ApiService(dio);
  final authService = AuthService(apiService, prefs);
  final authRepository = AuthRepository(authService);

  runApp(BepVietApp(
    authRepository: authRepository,
    apiService: apiService,
    authService: authService,
  ));
}

class BepVietApp extends StatefulWidget {
  final AuthRepository authRepository;
  final ApiService apiService;
  final AuthService authService;

  const BepVietApp({
    super.key,
    required this.authRepository,
    required this.apiService,
    required this.authService,
  });

  @override
  State<BepVietApp> createState() => _BepVietAppState();
}

class _BepVietAppState extends State<BepVietApp> {
  late final AuthCubit _authCubit;
  late final MealPlanCubit _mealPlanCubit;
  late final ShoppingListCubit _shoppingListCubit;
  late final PantryCubit _pantryCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(widget.authRepository);
    _mealPlanCubit = MealPlanCubit(widget.apiService, widget.authService);
    _shoppingListCubit = ShoppingListCubit(widget.apiService, widget.authService);
    _pantryCubit = PantryCubit(widget.apiService, widget.authService);
    _router = AppRouter.router(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _mealPlanCubit.close();
    _shoppingListCubit.close();
    _pantryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiService>.value(value: widget.apiService),
        RepositoryProvider<AuthService>.value(value: widget.authService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: _authCubit),
          BlocProvider<MealPlanCubit>.value(value: _mealPlanCubit),
          BlocProvider<ShoppingListCubit>.value(value: _shoppingListCubit),
          BlocProvider<PantryCubit>.value(value: _pantryCubit),
        ],
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            // Show splash screen while checking auth
            if (state is AuthInitial) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                home: const _SplashScreen(),
              );
            }

            return MaterialApp.router(
              title: AppConfig.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              routerConfig: _router,
            );
          },
        ),
      ),
    );
  }
}

// Splash Screen
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 60,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 32),
              // App Name
              const Text(
                'Bếp Việt',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hôm nay ăn gì, có Bếp Việt lo',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              // Loading Indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
