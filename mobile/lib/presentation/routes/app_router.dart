import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/presentation/features/home/pages/home_page.dart';
import 'package:bepviet_mobile/presentation/features/suggest/pages/suggest_page.dart';
import 'package:bepviet_mobile/presentation/features/recipes/pages/recipes_page.dart';
import 'package:bepviet_mobile/presentation/features/recipes/pages/recipe_detail_page.dart';
import 'package:bepviet_mobile/presentation/features/favorites/pages/favorites_page.dart';
import 'package:bepviet_mobile/presentation/features/planner/pages/planner_page.dart';
import 'package:bepviet_mobile/presentation/features/pantry/pages/pantry_page.dart';
import 'package:bepviet_mobile/presentation/features/community/pages/community_page.dart';
import 'package:bepviet_mobile/presentation/features/personal/pages/personal_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/pages/login_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/pages/register_page.dart';
import 'package:bepviet_mobile/presentation/widgets/main_navigation.dart';
import 'package:bepviet_mobile/presentation/features/suggest/pages/ai_suggest_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/cubit/auth_cubit.dart';

class AppRoutes {
  // Main routes
  static const String home = '/';
  static const String suggest = '/suggest';
  static const String recipes = '/recipes';
  static const String planner = '/planner';
  static const String pantry = '/pantry';
  static const String community = '/community';

  // Auth routes
  static const String login = '/login';
  static const String register = '/register';

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
}

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    final authNotifier = AuthNotifier(authCubit);

    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final isAuthenticated = authCubit.state is AuthAuthenticated;
        final isLoggingIn = state.matchedLocation == AppRoutes.login;
        final isRegistering = state.matchedLocation == AppRoutes.register;

        // If not authenticated and not on auth pages, redirect to login
        if (!isAuthenticated && !isLoggingIn && !isRegistering) {
          return AppRoutes.login;
        }

        // If authenticated and on auth pages, redirect to home
        if (isAuthenticated && (isLoggingIn || isRegistering)) {
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
              path: AppRoutes.community,
              name: 'community',
              builder: (context, state) => const CommunityPage(),
            ),
            GoRoute(
              path: '/profile',
              name: 'profile',
              builder: (context, state) => const ProfilePage(),
            ),
            // AI Suggest standalone page
            GoRoute(
              path: '/ai-suggest',
              name: 'ai-suggest',
              builder: (context, state) => const AiSuggestPage(),
            ),
          ],
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
