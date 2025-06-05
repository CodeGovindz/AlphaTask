import 'package:flutter/material.dart';
import '../models/task.dart';
import '../db/task_db.dart';
import 'sync_service.dart';
import 'sentiment_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  bool _isOnline = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks = await TaskDB().getTasks();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final sentiment = await SentimentService().analyze(task.description);
    await TaskDB().insertTask(task.copyWith(sentiment: sentiment));
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final sentiment = await SentimentService().analyze(task.description);
    await TaskDB().updateTask(task.copyWith(sentiment: sentiment));
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await TaskDB().deleteTask(id);
    await loadTasks();
  }

  void toggleOnline() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  Future<void> syncWithServer() async {
    if (_isOnline) {
      // Download server tasks
      final serverTasks = await SyncService.downloadTasks();
      // Resolve conflicts (last write wins)
      final merged = SyncService.resolveConflicts(_tasks, serverTasks);
      // Upload merged tasks to server
      await SyncService.uploadTasks(merged);
      // Update local DB
      for (final task in merged) {
        await TaskDB().insertTask(task);
      }
      await loadTasks();
    }
  }
}
