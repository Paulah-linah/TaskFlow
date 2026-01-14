import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../utils/theme_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Function(String) onToggle;
  final Function(String) onDelete;
  final Function(Task) onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final today = DateTime.now().toIso8601String().split('T')[0];
    final isOverdue = !task.completed && task.dueDate.compareTo(today) < 0;

    return Card(
      margin: EdgeInsets.zero,
      color: task.completed
          ? Theme.of(context).colorScheme.surface
          : isOverdue
              ? Colors.red.withOpacity(0.05)
              : Theme.of(context).colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: task.completed
              ? Theme.of(context).colorScheme.outline.withOpacity(0.1)
              : isOverdue
                  ? Colors.red.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          children: [
            if (isOverdue)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCheckbox(context, isOverdue),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, themeProvider, isOverdue),
                        const SizedBox(height: 8),
                        _buildDescription(context, isOverdue),
                        const SizedBox(height: 16),
                        _buildFooter(context, isOverdue),
                      ],
                    ),
                  ),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildCheckbox(BuildContext context, bool isOverdue) {
    return GestureDetector(
      onTap: () => onToggle(task.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: task.completed
              ? Provider.of<ThemeProvider>(context).accentColorLight
              : Colors.transparent,
          border: Border.all(
            color: task.completed
                ? Provider.of<ThemeProvider>(context).accentColorLight
                : isOverdue
                    ? Colors.red
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: task.completed
            ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
            : null,
      ).animate()
        .scale(duration: 200.ms, curve: Curves.easeInOut),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeProvider themeProvider, bool isOverdue) {
    return Row(
      children: [
        Expanded(
          child: Text(
            task.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              decoration: task.completed ? TextDecoration.lineThrough : null,
              color: task.completed
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                  : isOverdue
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (isOverdue)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning, size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  'Overdue',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ).animate()
            .shimmer(duration: 1500.ms, delay: 500.ms),
        const SizedBox(width: 4),
        _buildPriorityBadge(context),
        const SizedBox(width: 4),
        _buildCategoryBadge(context),
      ],
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color color;
    IconData icon;
    
    switch (task.priority) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            task.priority.displayName,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    Color color;
    
    switch (task.category) {
      case TaskCategory.work:
        color = Colors.blue;
        break;
      case TaskCategory.personal:
        color = Colors.purple;
        break;
      case TaskCategory.urgent:
        color = Colors.red;
        break;
      case TaskCategory.shopping:
        color = Colors.green;
        break;
      case TaskCategory.others:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        task.category.displayName,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDescription(BuildContext context, bool isOverdue) {
    return Text(
      task.description.isEmpty ? "No description provided." : task.description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: task.completed
            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
            : isOverdue
                ? Colors.red.withOpacity(0.7)
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        fontWeight: FontWeight.w500,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context, bool isOverdue) {
    final dateFormat = DateFormat('MMM d');
    final dueDate = DateTime.parse(task.dueDate);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isOverdue
                ? Colors.red.withOpacity(0.1)
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: isOverdue
                ? Border.all(color: Colors.red.withOpacity(0.3))
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: isOverdue
                    ? Colors.red
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                dateFormat.format(dueDate),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOverdue
                      ? Colors.red
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (task.reminder?.enabled == true) ...[
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Provider.of<ThemeProvider>(context).accentColorLight.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications,
                  size: 14,
                  color: Provider.of<ThemeProvider>(context).accentColorLight,
                ),
                const SizedBox(width: 6),
                Text(
                  '${task.reminder!.time} • ${task.reminder!.frequency.displayName}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Provider.of<ThemeProvider>(context).accentColorLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: () => onEdit(task),
          icon: const Icon(Icons.more_vert),
          iconSize: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 8),
        IconButton(
          onPressed: () => onDelete(task.id),
          icon: const Icon(Icons.delete),
          iconSize: 20,
          color: Colors.red,
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ).animate()
      .fadeIn(delay: 200.ms)
      .slideX(begin: 0.2, end: 0, duration: 300.ms);
  }
}
