import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bepviet_mobile/core/theme/app_theme.dart';

class MainNavigation extends StatefulWidget {
  final Widget child;

  const MainNavigation({super.key, required this.child});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Trang chủ',
      route: '/',
    ),
    NavigationItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search_rounded,
      label: 'Gợi ý',
      route: '/suggest',
    ),
    NavigationItem(
      icon: Icons.event_note_outlined,
      activeIcon: Icons.event_note_rounded,
      label: 'Kế hoạch',
      route: '/planner',
    ),
    NavigationItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Tủ lạnh',
      route: '/pantry',
    ),
    NavigationItem(
      icon: Icons.public_outlined,
      activeIcon: Icons.public,
      label: 'Cộng đồng',
      route: '/community',
    ),
    NavigationItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 150),
        vsync: this,
      ),
    );
    _scaleAnimations = _animationControllers
        .map(
          (controller) => Tween<double>(
            begin: 1.0,
            end: 0.92,
          ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut)),
        )
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    // Animate old item out
    _animationControllers[_currentIndex].reverse();

    setState(() {
      _currentIndex = index;
    });

    // Animate new item in
    _animationControllers[index].forward();

    context.go(_navigationItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade100, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _navigationItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _currentIndex == index;

                  return Expanded(
                    child: _NavigationButton(
                      item: item,
                      isSelected: isSelected,
                      scaleAnimation: _scaleAnimations[index],
                      onTap: () => _onItemTapped(index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatefulWidget {
  final NavigationItem item;
  final bool isSelected;
  final Animation<double> scaleAnimation;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.item,
    required this.isSelected,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  State<_NavigationButton> createState() => _NavigationButtonState();
}

class _NavigationButtonState extends State<_NavigationButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.fastOutSlowIn),
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _rippleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect (only show when animating)
            AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                if (_rippleAnimation.value == 0) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: 52 + (_rippleAnimation.value * 24),
                  height: 52 + (_rippleAnimation.value * 24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryGreen.withOpacity(
                      0.12 * (1 - _rippleAnimation.value),
                    ),
                  ),
                );
              },
            ),
            // Main content
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                SizedBox(
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle for active state with smooth animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.fastOutSlowIn,
                        tween: Tween<double>(
                          begin: 0,
                          end: widget.isSelected ? 1 : 0,
                        ),
                        builder: (context, value, child) {
                          return Container(
                            width: 48 * value,
                            height: 48 * value,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.primaryGreen.withOpacity(
                                    0.16 * value,
                                  ),
                                  AppTheme.primaryGreen.withOpacity(
                                    0.08 * value,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Icon with smooth transition
                      ScaleTransition(
                        scale: widget.scaleAnimation,
                        child: Icon(
                          widget.isSelected
                              ? widget.item.activeIcon
                              : widget.item.icon,
                          color: widget.isSelected
                              ? AppTheme.primaryGreen
                              : Colors.grey.shade500,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                // Active indicator - smaller dot
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.fastOutSlowIn,
                  tween: Tween<double>(
                    begin: 0,
                    end: widget.isSelected ? 1 : 0,
                  ),
                  builder: (context, value, child) {
                    return Container(
                      width: 5 * value,
                      height: 5 * value,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
