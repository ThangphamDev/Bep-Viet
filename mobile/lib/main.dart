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
import 'data/sources/remote/websocket_service.dart';
import 'data/sources/local/push_notification_service.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/premium_repository.dart';
import 'presentation/features/auth/cubit/auth_cubit.dart';
import 'presentation/features/premium/cubit/premium_cubit.dart';
import 'presentation/features/notifications/cubit/notifications_cubit.dart';

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
  final googleAuthService = GoogleAuthService(dio);
  final biometricAuthService = BiometricAuthService();
  final authRepository = AuthRepository(
    authService,
    googleAuthService,
    biometricAuthService,
  );
  final premiumService = PremiumService(dio);
  final premiumRepository = PremiumRepository(premiumService);
  final webSocketService = WebSocketService();
  final pushNotificationService = PushNotificationService();

  runApp(
    BepVietApp(
      authRepository: authRepository,
      premiumRepository: premiumRepository,
      apiService: apiService,
      authService: authService,
      webSocketService: webSocketService,
      pushNotificationService: pushNotificationService,
    ),
  );
}

class BepVietApp extends StatefulWidget {
  final AuthRepository authRepository;
  final PremiumRepository premiumRepository;
  final ApiService apiService;
  final AuthService authService;
  final WebSocketService webSocketService;
  final PushNotificationService pushNotificationService;

  const BepVietApp({
    super.key,
    required this.authRepository,
    required this.premiumRepository,
    required this.apiService,
    required this.authService,
    required this.webSocketService,
    required this.pushNotificationService,
  });

  @override
  State<BepVietApp> createState() => _BepVietAppState();
}

class _BepVietAppState extends State<BepVietApp> {
  late final AuthCubit _authCubit;
  late final PremiumCubit _premiumCubit;
  late final MealPlanCubit _mealPlanCubit;
  late final ShoppingListCubit _shoppingListCubit;
  late final PantryCubit _pantryCubit;
  late final NotificationsCubit _notificationsCubit;
  late final GoRouter _router;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int _lastNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _authCubit = AuthCubit(widget.authRepository);
    _premiumCubit = PremiumCubit(widget.premiumRepository);
    _mealPlanCubit = MealPlanCubit(widget.apiService, widget.authService);
    _shoppingListCubit = ShoppingListCubit(
      widget.apiService,
      widget.authService,
    );
    _pantryCubit = PantryCubit(widget.apiService, widget.authService);
    _notificationsCubit = NotificationsCubit(
      webSocketService: widget.webSocketService,
      pushNotificationService: widget.pushNotificationService,
    );
    _router = AppRouter.router(_authCubit);

    // Initialize push notifications
    _initializePushNotifications();

    // Listen to auth state changes to connect/disconnect WebSocket
    _authCubit.stream.listen((authState) async {
      if (authState is AuthAuthenticated) {
        final token = widget.authRepository.accessToken;
        if (token != null) {
          widget.webSocketService.connect(token);

          // Wait for connection then fetch history
          await Future.delayed(const Duration(milliseconds: 1500));
          await _notificationsCubit.fetchHistory();
        }
      } else if (authState is AuthUnauthenticated) {
        widget.webSocketService.disconnect();
        _notificationsCubit.loadNotifications([]);
      }
    });

    // Listen to notifications to show snackbar for new ones
    _notificationsCubit.stream.listen((notificationState) {
      if (notificationState is NotificationsLoaded) {
        final currentCount = notificationState.notifications.length;
        // Show snackbar only if count increased (new notification)
        if (currentCount > _lastNotificationCount &&
            _lastNotificationCount > 0) {
          final latestNotification = notificationState.notifications.first;
          _scaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Text(
                    latestNotification.iconByType,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          latestNotification.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (latestNotification.body.isNotEmpty)
                          Text(
                            latestNotification.body,
                            style: const TextStyle(color: Colors.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.primaryGreen,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Xem',
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to notifications page
                  _router.go('/notifications');
                },
              ),
            ),
          );
        }
        _lastNotificationCount = currentCount;
      }
    });
  }

  Future<void> _initializePushNotifications() async {
    await widget.pushNotificationService.initialize(
      onNotificationTap: (notificationId) {
        // Navigate to notifications page when user taps notification
        _router.go('/notifications');
      },
    );
  }

  @override
  void dispose() {
    _authCubit.close();
    _premiumCubit.close();
    _mealPlanCubit.close();
    _shoppingListCubit.close();
    _pantryCubit.close();
    _notificationsCubit.close();
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
          BlocProvider<PremiumCubit>.value(value: _premiumCubit),
          BlocProvider<MealPlanCubit>.value(value: _mealPlanCubit),
          BlocProvider<ShoppingListCubit>.value(value: _shoppingListCubit),
          BlocProvider<PantryCubit>.value(value: _pantryCubit),
          BlocProvider<NotificationsCubit>.value(value: _notificationsCubit),
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
              scaffoldMessengerKey: _scaffoldMessengerKey,
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
