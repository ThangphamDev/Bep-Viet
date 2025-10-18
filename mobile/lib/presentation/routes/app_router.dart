import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/presentation/features/home/pages/home_page.dart';
import 'package:bepviet_mobile/presentation/features/suggest/pages/suggest_page.dart';
import 'package:bepviet_mobile/presentation/features/recipes/pages/recipes_page.dart';
import 'package:bepviet_mobile/presentation/features/planner/pages/planner_page.dart';
import 'package:bepviet_mobile/presentation/features/pantry/pages/pantry_page.dart';
import 'package:bepviet_mobile/presentation/features/community/pages/community_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/pages/login_page.dart';
import 'package:bepviet_mobile/presentation/features/auth/pages/register_page.dart';
import 'package:bepviet_mobile/presentation/widgets/main_navigation.dart';

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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
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
