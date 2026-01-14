enum TaskCategory {
  work('Work'),
  personal('Personal'),
  urgent('Urgent'),
  shopping('Shopping'),
  others('Others');

  const TaskCategory(this.displayName);
  final String displayName;
}

enum TaskPriority {
  low('Low'),
  medium('Medium'),
  high('High');

  const TaskPriority(this.displayName);
  final String displayName;
}

enum ReminderFrequency {
  once('Once'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const ReminderFrequency(this.displayName);
  final String displayName;
}

enum AppThemeMode {
  light('light'),
  dark('dark');

  const AppThemeMode(this.value);
  final String value;
}

enum AccentTheme {
  indigo('indigo'),
  rose('rose'),
  emerald('emerald'),
  amber('amber'),
  violet('violet');

  const AccentTheme(this.value);
  final String value;
}

class Reminder {
  final bool enabled;
  final String time;
  final ReminderFrequency frequency;

  const Reminder({
    required this.enabled,
    required this.time,
    required this.frequency,
  });

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'time': time,
      'frequency': frequency.name,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      enabled: map['enabled'] ?? false,
      time: map['time'] ?? '',
      frequency: ReminderFrequency.values.firstWhere(
        (f) => f.name == map['frequency'],
        orElse: () => ReminderFrequency.once,
      ),
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final TaskCategory category;
  final TaskPriority priority;
  final String dueDate;
  final bool completed;
  final int createdAt;
  final Reminder? reminder;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.dueDate,
    required this.completed,
    required this.createdAt,
    this.reminder,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    String? dueDate,
    bool? completed,
    int? createdAt,
    Reminder? reminder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      reminder: reminder ?? this.reminder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'dueDate': dueDate,
      'completed': completed,
      'createdAt': createdAt,
      'reminder': reminder?.toMap(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: TaskCategory.values.firstWhere(
        (c) => c.name == map['category'],
        orElse: () => TaskCategory.others,
      ),
      priority: TaskPriority.values.firstWhere(
        (p) => p.name == map['priority'],
        orElse: () => TaskPriority.low,
      ),
      dueDate: map['dueDate'] ?? '',
      completed: map['completed'] ?? false,
      createdAt: map['createdAt'] ?? 0,
      reminder: map['reminder'] != null ? Reminder.fromMap(map['reminder']) : null,
    );
  }
}

class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final List<CategoryDistribution> categoryDistribution;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.categoryDistribution,
  });

  factory TaskStats.fromTasks(List<Task> tasks) {
    final total = tasks.length;
    final completed = tasks.where((t) => t.completed).length;
    final pending = total - completed;
    
    final categoryCount = <TaskCategory, int>{};
    for (final task in tasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
    }
    
    final categoryDistribution = categoryCount.entries
        .map((entry) => CategoryDistribution(
              name: entry.key.displayName,
              value: entry.value,
            ))
        .toList();

    return TaskStats(
      total: total,
      completed: completed,
      pending: pending,
      categoryDistribution: categoryDistribution,
    );
  }
}

class CategoryDistribution {
  final String name;
  final int value;

  const CategoryDistribution({
    required this.name,
    required this.value,
  });
}
