import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../utils/theme_provider.dart';

class TaskForm extends StatefulWidget {
  final Task? initialTask;
  final Function({
    required String title,
    required String description,
    required TaskCategory category,
    required TaskPriority priority,
    required String dueDate,
    Reminder? reminder,
  }) onSubmit;
  final VoidCallback onClose;

  const TaskForm({
    super.key,
    this.initialTask,
    required this.onSubmit,
    required this.onClose,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskCategory _category;
  late TaskPriority _priority;
  late String _dueDate;
  bool _reminderEnabled = false;
  String _reminderTime = '09:00';
  ReminderFrequency _reminderFrequency = ReminderFrequency.once;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialTask?.description ?? '');
    _category = widget.initialTask?.category ?? TaskCategory.work;
    _priority = widget.initialTask?.priority ?? TaskPriority.medium;
    _dueDate = widget.initialTask?.dueDate ?? DateTime.now().toIso8601String().split('T')[0];
    
    if (widget.initialTask?.reminder != null) {
      _reminderEnabled = widget.initialTask!.reminder!.enabled;
      _reminderTime = widget.initialTask!.reminder!.time;
      _reminderFrequency = widget.initialTask!.reminder!.frequency;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _setRelativeDate(int days) {
    final date = DateTime.now().add(Duration(days: days));
    setState(() {
      _dueDate = date.toIso8601String().split('T')[0];
    });
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final reminder = _reminderEnabled
          ? Reminder(
              enabled: true,
              time: _reminderTime,
              frequency: _reminderFrequency,
            )
          : null;

      widget.onSubmit(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        priority: _priority,
        dueDate: _dueDate,
        reminder: reminder,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleField(context),
                      const SizedBox(height: 24),
                      _buildPrioritySelector(context),
                      const SizedBox(height: 24),
                      _buildDescriptionField(context),
                      const SizedBox(height: 24),
                      _buildDueDateSection(context),
                      const SizedBox(height: 24),
                      _buildCategorySelector(context),
                      const SizedBox(height: 24),
                      _buildReminderSection(context),
                      const SizedBox(height: 32),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate()
        .scale(duration: 300.ms, curve: Curves.easeOut)
        .fadeIn(duration: 300.ms),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.initialTask != null ? 'Edit Task' : 'New Task',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plan your next big move',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Title',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Design Landing Page',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Provider.of<ThemeProvider>(context).accentColorLight,
                width: 2,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a task title';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPrioritySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: TaskPriority.values.map((priority) {
            final isSelected = _priority == priority;
            Color color;
            IconData icon;
            
            switch (priority) {
              case TaskPriority.high:
                color = Colors.red;
                icon = Icons.priority_high;
                break;
              case TaskPriority.medium:
                color = Colors.amber;
                icon = Icons.remove;
                break;
              case TaskPriority.low:
                color = Colors.green;
                icon = Icons.keyboard_arrow_down;
                break;
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _priority = priority),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? color.withOpacity(0.1)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? color.withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? color : Theme.of(context).colorScheme.surfaceContainerHighest,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        priority.displayName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? color : Theme.of(context).colorScheme.surfaceContainerHighest,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add some context...',
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Provider.of<ThemeProvider>(context).accentColorLight,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.parse(_dueDate),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              setState(() {
                _dueDate = date.toIso8601String().split('T')[0];
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Select due date',
            prefixIcon: const Icon(Icons.calendar_today),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Provider.of<ThemeProvider>(context).accentColorLight,
                width: 2,
              ),
            ),
          ),
          controller: TextEditingController(
            text: _dueDate,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            _buildQuickDateButton('Today', 0),
            _buildQuickDateButton('Tomorrow', 1),
            _buildQuickDateButton('Next Week', 7),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(String label, int days) {
    return ElevatedButton(
      onPressed: () => _setRelativeDate(days),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<TaskCategory>(
          value: _category,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Provider.of<ThemeProvider>(context).accentColorLight,
                width: 2,
              ),
            ),
          ),
          items: TaskCategory.values.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category.displayName),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _category = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildReminderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _reminderEnabled
                          ? Provider.of<ThemeProvider>(context).accentColorLight.withOpacity(0.1)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: _reminderEnabled
                          ? Provider.of<ThemeProvider>(context).accentColorLight
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Task Reminder',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Get notified about this task',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _reminderEnabled,
                    onChanged: (value) => setState(() => _reminderEnabled = value),
                    activeColor: Provider.of<ThemeProvider>(context).accentColorLight,
                  ),
                ],
              ),
              if (_reminderEnabled) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.parse(_reminderTime.split(':')[0]),
                              minute: int.parse(_reminderTime.split(':')[1]),
                            ),
                          );
                          if (time != null) {
                            setState(() {
                              _reminderTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Time',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        controller: TextEditingController(text: _reminderTime),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<ReminderFrequency>(
                        value: _reminderFrequency,
                        decoration: InputDecoration(
                          labelText: 'Frequency',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: ReminderFrequency.values.map((frequency) {
                          return DropdownMenuItem(
                            value: frequency,
                            child: Text(frequency.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _reminderFrequency = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ).animate()
          .fadeIn(duration: 300.ms),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onClose,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Provider.of<ThemeProvider>(context).accentColorLight,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.initialTask != null ? 'Update Task' : 'Create Task',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
