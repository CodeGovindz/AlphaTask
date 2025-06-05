import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/task_provider.dart';
import 'task_list_screen.dart' show TaskListScreen;
import '../widgets/nav_bar_painter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'add_edit_task_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF181C2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Colors.cyanAccent, Colors.pinkAccent],
            ).createShader(bounds);
          },
          child: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1.1,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download, color: Colors.cyanAccent),
                      title: const Text(
                        'Download Your Tasks',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () async {
                        final provider = Provider.of<TaskProvider>(context, listen: false);
                        final tasks = provider.tasks;
                        if (tasks.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No tasks to export!')),
                          );
                          return;
                        }
                        // Prepare CSV data
                        List<List<dynamic>> rows = [
                          ['id', 'title', 'description', 'status', 'sentiment'],
                          ...tasks.map((t) => [t.id, t.title, t.description, t.status, t.sentiment]),
                        ];
                        String csvData = const ListToCsvConverter().convert(rows);
                        // Get Downloads directory
                        Directory? downloadsDir;
                        try {
                          downloadsDir = await getDownloadsDirectory();
                        } catch (_) {
                          downloadsDir = await getApplicationDocumentsDirectory();
                        }
                        final now = DateTime.now();
                        final fileName = 'tasks_${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}.csv';
                        final filePath = downloadsDir != null ? '${downloadsDir.path}/$fileName' : fileName;
                        final file = File(filePath);
                        await file.writeAsString(csvData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tasks exported to $filePath')),
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: Colors.white.withOpacity(0.10),
                      hoverColor: Colors.cyanAccent.withOpacity(0.08),
                    ),
                    const SizedBox(height: 24),
                    // Made with love by Govind
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Made with ',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                        Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                          size: 18,
                        ),
                        Text(
                          ' by Govind',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _SettingsBottomNavBar(),
    );
  }
}

class _SettingsBottomNavBar extends StatelessWidget {
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
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const TaskListScreen()),
                    );
                  },
                  child: Icon(Icons.home, color: Colors.cyanAccent, size: 32),
                ),
                const SizedBox(width: 60), // Space for plus button
                Icon(Icons.settings, color: Colors.pinkAccent, size: 32), // Not tappable, pink
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
                // After adding, pop to home
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const TaskListScreen()),
                  (route) => false,
                );
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