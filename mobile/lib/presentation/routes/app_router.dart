import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/presentation/features/home/pages/home_page.dart';
import 'package:bepviet_mobile/presentation/features/suggest/pages/suggest_page.dart';
import 'package:bepviet_mobile/presentation/features/recipes/pages/recipes_page.dart';
import 'package:bepviet_mobile/presentation/features/recipes/pages/recipe_detail_page.dart';
import 'package:bepviet_mobile/presentation/features/favorites/pages/favorites_page.dart';
import 'package:bepviet_mobile/presentation/features/planner/pages/planner_page.dart';
import 'package:bepviet_mobile/presentation/features/pantry/pages/pantry_page.dart';
import 'package:bepviet_mobile/presentation/features/shopping/pages/shopping_list_page.dart';
import 'package:bepviet_mobile/presentation/features/community/pages/community_page.dart';
import 'package:bepviet_mobile/presentation/features/personal/pages/personal_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/pages/login_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/pages/register_page.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/premium_dashboard_page.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/family_profile_page.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/advisory_page.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/subscription_page.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/weekly_report_page.dart';
import 'package:bepviet_mobile/presentation/features/premium/pages/ai_advisor_page.dart';
import 'package:bepviet_mobile/presentation/widgets/main_navigation.dart';
import 'package:bepviet_mobile/presentation/features/suggest/pages/ai_suggest_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';
import 'package:bepviet_mobile/data/models/user_model.dart';

// Admin imports
import 'package:bepviet_mobile/presentation/features/admin/pages/admin_main_page.dart';

class AppRoutes {
  // Main routes
  static const String home = '/';
  static const String suggest = '/suggest';
  static const String recipes = '/recipes';
  static const String planner = '/planner';
  static const String pantry = '/pantry';
  static const String community = '/community';
  static const String shopping = '/shopping';

  // Admin routes
  static const String admin = '/admin';

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

  // Premium routes
  static const String premium = '/premium';
  static const String premiumFamily = '/premium/family';
  static const String premiumAdvisory = '/premium/advisory';
  static const String premiumSubscription = '/premium/subscription';
  static const String premiumReport = '/premium/report';
  static const String premiumAIAdvisor = '/premium/ai-advisor';

  // Detail routes
  static const String recipeDetail = '/recipes/:id';
  static const String shoppingList = '/shopping/:id';
}

// Auth state notifier for GoRouter
class AuthNotifier extends ChangeNotifier {
  final AuthCubit _authCubit;

  AuthNotifier(this._authCubit) {
    _authCubit.stream.listen((_) {
      notifyListeners();
    });
  }

  bool get isAuthenticated => _authCubit.state is AuthAuthenticated;

  bool get isAdmin {
    if (_authCubit.state is AuthAuthenticated) {
      final state = _authCubit.state as AuthAuthenticated;
      return state.user.role == 'ADMIN';
    }
    return false;
  }

  UserModel? get currentUser {
    if (_authCubit.state is AuthAuthenticated) {
      final state = _authCubit.state as AuthAuthenticated;
      return state.user;
    }
    return null;
  }
}

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    final authNotifier = AuthNotifier(authCubit);

    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final authState = authCubit.state;

        // Show splash (stay on current route) while checking auth
        if (authState is AuthInitial) {
          return null;
        }

        final isAuthenticated = authState is AuthAuthenticated;
        final isLoggingIn = state.matchedLocation == AppRoutes.login;
        final isRegistering = state.matchedLocation == AppRoutes.register;
        final isAdminRoute = state.matchedLocation.startsWith('/admin');

        // If not authenticated and not on auth pages, redirect to login
        if (!isAuthenticated && !isLoggingIn && !isRegistering) {
          return AppRoutes.login;
        }

        // REMOVED: Auto-redirect when authenticated on login page
        // Now users can stay on login page to use biometric authentication

        // If trying to access admin routes but not admin, redirect to home
        if (isAuthenticated && isAdminRoute && !authNotifier.isAdmin) {
          return AppRoutes.home;
        }

        // Allow access to the requested route
        return null;
      },
      routes: [
        // Main shell with bottom navigation
        ShellRoute(
          builder: (context, state, child) {
            return MainNavigation(child: child);
          },
          routes: [
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (context, state) => const HomePage(),
            ),
            GoRoute(
              path: AppRoutes.suggest,
              name: 'suggest',
              builder: (context, state) => const SuggestPage(),
            ),
            // Recipes route (accessible via button from suggest page)
            GoRoute(
              path: AppRoutes.recipes,
              name: 'recipes',
              builder: (context, state) => const RecipesPage(),
              routes: [
                GoRoute(
                  path: '/:id',
                  name: 'recipe-detail',
                  builder: (context, state) {
                    final recipeId = state.pathParameters['id']!;
                    return RecipeDetailPage(recipeId: recipeId);
                  },
                ),
              ],
            ),
            // Favorites route
            GoRoute(
              path: '/favorites',
              name: 'favorites',
              builder: (context, state) => const FavoritesPage(),
            ),
            GoRoute(
              path: AppRoutes.planner,
              name: 'planner',
              builder: (context, state) => const PlannerPage(),
            ),
            GoRoute(
              path: AppRoutes.pantry,
              name: 'pantry',
              builder: (context, state) => const PantryPage(),
            ),
            GoRoute(
              path: AppRoutes.shopping,
              name: 'shopping',
              builder: (context, state) => const ShoppingListPage(),
            ),
            GoRoute(
              path: AppRoutes.community,
              name: 'community',
              builder: (context, state) => const CommunityPage(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
            // Premium routes
            GoRoute(
              path: AppRoutes.premium,
              name: 'premium',
              builder: (context, state) => const PremiumDashboardPage(),
            ),
            GoRoute(
              path: AppRoutes.premiumFamily,
              name: 'premium-family',
              builder: (context, state) => const FamilyProfilePage(),
            ),
            GoRoute(
              path: AppRoutes.premiumAdvisory,
              name: 'premium-advisory',
              builder: (context, state) => const AdvisoryPage(),
            ),
            GoRoute(
              path: AppRoutes.premiumSubscription,
              name: 'premium-subscription',
              builder: (context, state) => const SubscriptionPage(),
            ),
            GoRoute(
              path: AppRoutes.premiumReport,
              name: 'premium-report',
              builder: (context, state) => const WeeklyReportPage(),
            ),
            GoRoute(
              path: AppRoutes.premiumAIAdvisor,
              name: 'premium-ai-advisor',
              builder: (context, state) => const AIAdvisorPage(),
            ),
            // AI Suggest standalone page
            GoRoute(
              path: '/ai-suggest',
              name: 'ai-suggest',
              builder: (context, state) => const AiSuggestPage(),
            ),
          ],
        ),

        // Admin route
        GoRoute(
          path: AppRoutes.admin,
          name: 'admin',
          builder: (context, state) => const AdminMainPage(),
        ),

        // Auth routes (without bottom navigation)
        GoRoute(
          path: AppRoutes.login,
          name: 'login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          name: 'register',
          builder: (context, state) => const RegisterPage(),
        ),
      ],
    );
  }
}
