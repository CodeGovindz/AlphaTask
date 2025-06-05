import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../services/task_provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;
  const AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  String _status = 'todo';

  @override
  void initState() {
    super.initState();
    _title = widget.task?.title ?? '';
    _description = widget.task?.description ?? '';
    _status = widget.task?.status ?? 'todo';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF181C2F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [Colors.cyanAccent, Colors.pinkAccent],
            ).createShader(bounds);
          },
          child: Text(
            widget.task == null ? 'Add Task' : 'Edit Task',
            style: const TextStyle(
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
        child: SingleChildScrollView(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _GlassyTextField(
                          initialValue: _title,
                          label: 'Title',
                          onSaved: (value) => _title = value!,
                          validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                        ),
                        const SizedBox(height: 18),
                        _GlassyTextField(
                          initialValue: _description,
                          label: 'Description',
                          onSaved: (value) => _description = value!,
                          validator: (value) => value == null || value.isEmpty ? 'Enter description' : null,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 18),
                        _StatusBarSelector(
                          value: _status,
                          onChanged: (value) => setState(() => _status = value),
                        ),
                        const SizedBox(height: 300),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              )),
                              padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 0)),
                              backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                                return Colors.transparent;
                              }),
                              shadowColor: MaterialStateProperty.all(Colors.pinkAccent.withOpacity(0.18)),
                              overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.04)),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final provider = Provider.of<TaskProvider>(context, listen: false);
                                if (widget.task == null) {
                                  await provider.addTask(Task(
                                    title: _title,
                                    description: _description,
                                    status: _status,
                                    sentiment: 'neutral',
                                  ));
                                } else {
                                  await provider.updateTask(widget.task!.copyWith(
                                    title: _title,
                                    description: _description,
                                    status: _status,
                                  ));
                                }
                                Navigator.pop(context);
                              }
                            },
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.cyanAccent, Colors.pinkAccent],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.pinkAccent.withOpacity(0.18),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.task == null ? 'Add' : 'Update',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 1.1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassyTextField extends StatelessWidget {
  final String initialValue;
  final String label;
  final FormFieldSetter<String> onSaved;
  final FormFieldValidator<String>? validator;
  final int maxLines;
  const _GlassyTextField({
    required this.initialValue,
    required this.label,
    required this.onSaved,
    this.validator,
    this.maxLines = 1,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.18), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.pinkAccent, width: 2),
        ),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}

class _StatusBarSelector extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _StatusBarSelector({required this.value, required this.onChanged});
  @override
  State<_StatusBarSelector> createState() => _StatusBarSelectorState();
}

class _StatusBarSelectorState extends State<_StatusBarSelector> {
  bool _showMenu = false;
  final List<Map<String, dynamic>> _options = [
    {'value': 'todo', 'label': 'To Do', 'color': Colors.blueAccent},
    {'value': 'in progress', 'label': 'In Progress', 'color': Colors.amberAccent},
    {'value': 'done', 'label': 'Done', 'color': Colors.greenAccent},
  ];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleMenu() {
    if (_showMenu) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _showMenu = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    setState(() => _showMenu = false);
  }

  OverlayEntry _buildOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    return OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height + 8,
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0, size.height + 8),
                child: Material(
                  color: Colors.transparent,
                  child: AnimatedOpacity(
                    opacity: _showMenu ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.13),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: _options.map((opt) {
                          final selected = widget.value == opt['value'];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                widget.onChanged(opt['value']);
                                _removeOverlay();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeInOut,
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? LinearGradient(
                                          colors: [opt['color'].withOpacity(0.7), Colors.pinkAccent.withOpacity(0.7)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: selected ? null : Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selected ? opt['color'] : Colors.white.withOpacity(0.13),
                                    width: 1.2,
                                  ),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: opt['color'].withOpacity(0.18),
                                            blurRadius: 12,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    opt['label'],
                                    style: TextStyle(
                                      color: selected ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = _options.firstWhere((o) => o['value'] == widget.value)['label'];
    final selectedColor = _options.firstWhere((o) => o['value'] == widget.value)['color'];
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selectedColor.withOpacity(0.5),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status: $selectedLabel',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(
                _showMenu ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: selectedColor,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 