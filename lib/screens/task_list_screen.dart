import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
import '../models/task.dart';
import 'add_edit_task_screen.dart';
import 'dart:ui';
import 'settings_screen.dart';
import '../widgets/nav_bar_painter.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  double _cloudRotation = 0;
  double _cloudScale = 1;
  bool _isAnimating = false;
  double _syncRotation = 0;
  bool _isSyncing = false;

  String _selectedStatus = 'all';

  void _animateCloud(VoidCallback onComplete) async {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
      _cloudRotation += 1;
      _cloudScale = 1.3;
    });
    await Future.delayed(const Duration(milliseconds: 220));
    setState(() {
      _cloudScale = 1;
    });
    await Future.delayed(const Duration(milliseconds: 180));
    setState(() {
      _isAnimating = false;
    });
    onComplete();
  }

  void _animateSync(Future<void> Function() onSync) async {
    if (_isSyncing) return;
    setState(() {
      _isSyncing = true;
    });
    for (int i = 0; i < 2; i++) {
      setState(() {
        _syncRotation += 1;
      });
      await Future.delayed(const Duration(milliseconds: 350));
    }
    await onSync();
    setState(() {
      _isSyncing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF181C2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.flash_on, color: Colors.cyanAccent, size: 28),
            const SizedBox(width: 8),
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Colors.cyanAccent, Colors.pinkAccent],
                ).createShader(bounds);
              },
              child: const Text(
                'AlphaTask',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, provider, _) => IconButton(
              icon: AnimatedRotation(
                turns: _cloudRotation,
                duration: const Duration(milliseconds: 400),
                child: AnimatedScale(
                  scale: _cloudScale,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.cloud,
                    color: provider.isOnline ? Colors.greenAccent : Colors.cyanAccent,
                  ),
                ),
              ),
              onPressed: () {
                _animateCloud(() {
                  provider.toggleOnline();
                });
              },
            ),
          ),
          Consumer<TaskProvider>(
            builder: (context, provider, _) => IconButton(
              icon: AnimatedRotation(
                turns: _syncRotation,
                duration: const Duration(milliseconds: 700),
                child: Icon(
                  Icons.sync,
                  color: provider.isOnline ? Colors.cyanAccent : Colors.white24,
                ),
              ),
              onPressed: provider.isOnline
                  ? () {
                      _animateSync(() => provider.syncWithServer());
                    }
                  : null,
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF181C2F), Color(0xFF23244D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline/Online Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Consumer<TaskProvider>(
                builder: (context, provider, _) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    provider.isOnline ? 'Online Mode' : 'Offline Mode',
                    style: TextStyle(
                      color: provider.isOnline ? Colors.greenAccent : Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Today's Tasks Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Tasks",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Wednesday, June 4',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
            // Status Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All Tasks', 'all'),
                    _buildFilterChip('To Do', 'todo'),
                    _buildFilterChip('In Progress', 'in progress'),
                    _buildFilterChip('Done', 'done'),
                  ],
                ),
              ),
            ),
            // Task List
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tasks = _selectedStatus == 'all'
                      ? provider.tasks
                      : provider.tasks.where((t) => t.status == _selectedStatus).toList();
                  if (tasks.isEmpty) {
                    return const Center(child: Text('No tasks found.', style: TextStyle(color: Colors.white70)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildTaskCard(context, task, provider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CustomBottomNavBar(),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _selectedStatus == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.cyanAccent, fontWeight: FontWeight.w600)),
        selected: selected,
        backgroundColor: selected
            ? Colors.cyanAccent
            : Colors.white.withOpacity(0.13),
        selectedColor: Colors.cyanAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? Colors.cyanAccent : Colors.white.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        onSelected: (_) {
          setState(() {
            _selectedStatus = value;
          });
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task, TaskProvider provider) {
    Color statusColor;
    String statusLabel;
    switch (task.status) {
      case 'done':
        statusColor = Colors.greenAccent;
        statusLabel = 'Done';
        break;
      case 'in progress':
        statusColor = Colors.amberAccent;
        statusLabel = 'In Progress';
        break;
      case 'todo':
        statusColor = Colors.blueAccent;
        statusLabel = 'To Do';
        break;
      default:
        statusColor = Colors.redAccent;
        statusLabel = task.status;
    }
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        title: Text(
          task.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration: task.status == 'done' ? TextDecoration.lineThrough : null,
            decorationColor: Colors.white38,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
                decoration: task.status == 'done' ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white38,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _sentimentColor(task.sentiment).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Sentiment: ${task.sentiment}',
                    style: TextStyle(
                      color: _sentimentColor(task.sentiment),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.cyanAccent),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditTaskScreen(task: task),
                  ),
                );
                provider.loadTasks();
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.pinkAccent),
              onPressed: () {
                provider.deleteTask(task.id!);
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _sentimentColor(String sentiment) {
    switch (sentiment) {
      case 'positive':
        return Colors.greenAccent;
      case 'negative':
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }
}

class _CustomBottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Blurry background for the bar
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: CustomPaint(
                  painter: NavBarPainter(),
                ),
              ),
            ),
          ),
          // Row for icons
          Positioned(
            left: 0,
            right: 0,
            top: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.home, color: Colors.cyanAccent, size: 32),
                const SizedBox(width: 60), // Space for plus button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                  child: Icon(Icons.settings, color: Colors.pinkAccent, size: 32),
                ),
              ],
            ),
          ),
          // Plus button (centered, above the bar)
          Positioned(
            top: 4,
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddEditTaskScreen(),
                  ),
                );
                Provider.of<TaskProvider>(context, listen: false).loadTasks();
              },
              child: Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.cyanAccent, Colors.pinkAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 40, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 