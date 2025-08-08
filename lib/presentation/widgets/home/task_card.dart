import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> tags;
  final bool isCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tags,
    this.isCompleted = false,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacing16),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacing16),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggleComplete,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted ? AppColors.primary : AppColors.outline,
                        width: 2,
                      ),
                      color: isCompleted ? AppColors.primary : Colors.transparent,
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: AppColors.onPrimary,
                            size: 16,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: AppConstants.spacing16),
                
                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                          color: isCompleted ? AppColors.onSurfaceVariant : AppColors.onSurface,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: AppConstants.spacing8),
                        Wrap(
                          spacing: AppConstants.spacing8,
                          children: tags.map((tag) => _buildTag(context, tag)).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Delete button (only show when task is completed or on long press)
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    Color tagColor;
    switch (tag.toLowerCase()) {
      case 'personal':
        tagColor = AppColors.secondary;
        break;
      case 'work':
        tagColor = AppColors.error;
        break;
      case 'study':
        tagColor = AppColors.lowPriority;
        break;
      case 'urgent':
        tagColor = AppColors.highPriority;
        break;
      default:
        tagColor = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacing12,
        vertical: AppConstants.spacing4,
      ),
      decoration: BoxDecoration(
        color: tagColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}