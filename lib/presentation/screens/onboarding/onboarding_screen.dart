import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/common/custom_app_icon.dart';
import '../../widgets/common/floating_elements.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Get things done.',
      subtitle: 'Just a click away from\nplanning your tasks',
      showNextButton: true,
    ),
    OnboardingPage(
      title: 'Stay organized.',
      subtitle: 'Manage your tasks\nefficiently and effectively',
      showNextButton: true,
    ),
    OnboardingPage(
      title: 'Let\'s get started!',
      subtitle: 'Create your account and\nstart organizing',
      showNextButton: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const FloatingElements(),
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_pages[index], index);
            },
          ),
          if (_currentPage < 2)
            Positioned(
              bottom: 60,
              right: 0,
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: AppConstants.animationDuration,
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: AppColors.onPrimary,
                    size: 32,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacing32),
      child: Column(
        children: [
          const Spacer(flex: 2),
          const CustomAppIcon(size: 120),
          const SizedBox(height: AppConstants.spacing48),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacing16),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
          if (index == 2) ...[
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                child: const Text('Get Started'),
              ),
            ),
            const SizedBox(height: AppConstants.spacing32),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (dotIndex) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: dotIndex == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotIndex == _currentPage
                        ? AppColors.primary
                        : AppColors.outline,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacing64),
          ],
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final bool showNextButton;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.showNextButton,
  });
}