import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/responsive_layout.dart';
import 'task_list_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';

/// Main navigation screen that handles bottom navigation
class MainNavigationScreen extends StatefulWidget {
  static const String routeName = '/main';

  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const TaskListScreen(),
    const CalendarScreen(),
    const ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildMobileLayout(),
      tablet: _buildTabletLayout(),
      desktop: _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Scaffold(
      body: Row(
        children: [
          // Side navigation for tablet
          Container(
            width: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // App logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.task_alt,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Navigation items
                  _buildSideNavItem(
                    icon: Icons.task_alt_outlined,
                    activeIcon: Icons.task_alt,
                    index: 0,
                    isActive: _currentIndex == 0,
                  ),
                  const SizedBox(height: 16),
                  _buildSideNavItem(
                    icon: Icons.calendar_today_outlined,
                    activeIcon: Icons.calendar_today,
                    index: 1,
                    isActive: _currentIndex == 1,
                  ),
                  const SizedBox(height: 16),
                  _buildSideNavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    index: 2,
                    isActive: _currentIndex == 2,
                  ),
                  const Spacer(),
                  // Logout button
                  IconButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthSignOutRequested());
                    },
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Main content
          Expanded(
            child: _screens[_currentIndex],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return _buildTabletLayout(); // Same as tablet for now
  }

  Widget _buildSideNavItem({
    required IconData icon,
    required IconData activeIcon,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive 
              ? Theme.of(context).colorScheme.primary 
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          size: 24,
        ),
      ),
    );
  }
}