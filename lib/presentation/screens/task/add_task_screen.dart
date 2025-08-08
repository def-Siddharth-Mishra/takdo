import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedPriority = 'Medium';
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _selectedTags = [];
  final List<String> _availableTags = ['Personal', 'Work', 'Study', 'Urgent', 'Health'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add New Task'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppColors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacing20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              Text(
                'Task Title',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter task title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Description field
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Enter task description (optional)',
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Due date
              Text(
                'Due Date',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacing16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.onSurfaceVariant,
                        size: AppConstants.iconMedium,
                      ),
                      const SizedBox(width: AppConstants.spacing12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select due date',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _selectedDate != null
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Priority
              Text(
                'Priority',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Row(
                children: _priorities.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  Color priorityColor;
                  switch (priority) {
                    case 'High':
                      priorityColor = AppColors.highPriority;
                      break;
                    case 'Medium':
                      priorityColor = AppColors.mediumPriority;
                      break;
                    case 'Low':
                      priorityColor = AppColors.lowPriority;
                      break;
                    default:
                      priorityColor = AppColors.primary;
                  }

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: priority != _priorities.last ? AppConstants.spacing8 : 0,
                      ),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
                          decoration: BoxDecoration(
                            color: isSelected ? priorityColor : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                            border: Border.all(
                              color: isSelected ? priorityColor : AppColors.outline,
                            ),
                          ),
                          child: Text(
                            priority,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing24),

              // Tags
              Text(
                'Tags',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacing8),
              Wrap(
                spacing: AppConstants.spacing8,
                runSpacing: AppConstants.spacing8,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedTags.remove(tag);
                        } else {
                          _selectedTags.add(tag);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacing16,
                        vertical: AppConstants.spacing8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.outline,
                        ),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacing40),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement save task logic with your existing bloc
      Navigator.of(context).pop({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDate': _selectedDate,
        'priority': _selectedPriority,
        'tags': _selectedTags,
      });
    }
  }
}