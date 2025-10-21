import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bepviet_mobile/core/config/app_config.dart';
import 'package:bepviet_mobile/presentation/features/home/pages/home_page.dart';
import 'package:bepviet_mobile/presentation/features/suggest/pages/suggest_page.dart';
import 'package:bepviet_mobile/presentation/features/recipes/pages/recipes_page.dart';
import 'package:bepviet_mobile/presentation/features/recipes/pages/recipe_detail_page.dart';
import 'package:bepviet_mobile/presentation/features/planner/pages/planner_page.dart';
import 'package:bepviet_mobile/presentation/features/pantry/pages/pantry_page.dart';
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

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    redirect: (context, state) async {
      // Check if user is authenticated
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.tokenKey);

      // If no token and trying to access protected routes, redirect to login
      if (token == null || token.isEmpty) {
        if (state.fullPath != AppRoutes.login &&
            state.fullPath != AppRoutes.register) {
          return AppRoutes.login;
        }
        return null; // Allow access to login/register pages
      }

      // If has token and trying to access login/register, redirect to home
      if (state.fullPath == AppRoutes.login ||
          state.fullPath == AppRoutes.register) {
        return AppRoutes.home;
      }

      // Allow access to other routes
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
