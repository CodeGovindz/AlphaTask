import '../models/task.dart';

class SyncService {
  // Simulated server-side task list
  static List<Task> _serverTasks = [];

  // Simulate uploading local tasks to the server
  static Future<void> uploadTasks(List<Task> localTasks) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // For simplicity, replace server tasks with local tasks
    _serverTasks = List.from(localTasks);
  }

  // Simulate downloading tasks from the server
  static Future<List<Task>> downloadTasks() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.from(_serverTasks);
  }

  // Simulate conflict resolution (last write wins)
  static List<Task> resolveConflicts(List<Task> localTasks, List<Task> serverTasks) {
    // For demo: merge by id, prefer local changes
    final Map<int, Task> merged = {for (var t in serverTasks) t.id!: t};
    for (var t in localTasks) {
      merged[t.id!] = t;
    }
    return merged.values.toList();
  }
} 