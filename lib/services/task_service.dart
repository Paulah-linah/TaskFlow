import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';

class TaskService {
  static const String _storageKey = 'taskflow_tasks_v1';
  static final Uuid _uuid = const Uuid();

  Future<List<Task>> getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_storageKey);
    
    if (data == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(data);
      return jsonList.map((json) => Task.fromMap(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(tasks.map((task) => task.toMap()).toList());
    await prefs.setString(_storageKey, data);
  }

  Future<Task> addTask({
    required String title,
    required String description,
    required TaskCategory category,
    required TaskPriority priority,
    required String dueDate,
    Reminder? reminder,
  }) async {
    final tasks = await getTasks();
    
    final newTask = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      priority: priority,
      dueDate: dueDate,
      completed: false,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      reminder: reminder,
    );
    
    await saveTasks([newTask, ...tasks]);
    return newTask;
  }

  Future<List<Task>> updateTask(String id, {
    String? title,
    String? description,
    TaskCategory? category,
    TaskPriority? priority,
    String? dueDate,
    bool? completed,
    Reminder? reminder,
  }) async {
    final tasks = await getTasks();
    
    final updatedTasks = tasks.map((task) {
      if (task.id == id) {
        return task.copyWith(
          title: title,
          description: description,
          category: category,
          priority: priority,
          dueDate: dueDate,
          completed: completed,
          reminder: reminder,
        );
      }
      return task;
    }).toList();
    
    await saveTasks(updatedTasks);
    return updatedTasks;
  }

  Future<List<Task>> deleteTask(String id) async {
    final tasks = await getTasks();
    final filteredTasks = tasks.where((task) => task.id != id).toList();
    await saveTasks(filteredTasks);
    return filteredTasks;
  }

  Future<TaskStats> getStats() async {
    final tasks = await getTasks();
    return TaskStats.fromTasks(tasks);
  }
}
