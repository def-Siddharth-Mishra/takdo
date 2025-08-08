import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onMorePressed;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.onMenuPressed,
    this.onSearchPressed,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppConstants.radiusXLarge),
          bottomRight: Radius.circular(AppConstants.radiusXLarge),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacing20,
            vertical: AppConstants.spacing16,
          ),
          child: Column(
            children: [
              // Top row with menu and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: onMenuPressed,
                    icon: const Icon(
                      Icons.apps,
                      color: AppColors.onPrimary,
                      size: AppConstants.iconMedium,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: onSearchPressed,
                        icon: const Icon(
                          Icons.search,
                          color: AppColors.onPrimary,
                          size: AppConstants.iconMedium,
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'filter':
                              // Handle filter
                              break;
                            case 'profile':
                              // Handle profile
                              break;
                            case 'logout':
                              // Handle logout
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'filter',
                            child: Row(
                              children: [
                                Icon(Icons.filter_list, size: 20),
                                SizedBox(width: 12),
                                Text('Filter'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'profile',
                            child: Row(
                              children: [
                                Icon(Icons.person, size: 20),
                                SizedBox(width: 12),
                                Text('Profile'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Row(
                              children: [
                                Icon(Icons.logout, size: 20),
                                SizedBox(width: 12),
                                Text('Logout'),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.onPrimary,
                          size: AppConstants.iconMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacing8),
              
              // Search bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.onPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusXLarge),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tasks...',
                    hintStyle: TextStyle(
                      color: AppColors.onPrimary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.onPrimary.withOpacity(0.7),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacing16,
                      vertical: AppConstants.spacing12,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing16),
              
              // Title and subtitle
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppConstants.appBarHeight + 40);
}