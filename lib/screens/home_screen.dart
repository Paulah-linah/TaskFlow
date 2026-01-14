import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../utils/theme_provider.dart';
import '../widgets/stats_dashboard.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskService _taskService = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = true;
  String _view = 'list';
  Task? _editingTask;

  String _searchTerm = '';
  String _statusFilter = 'All';
  TaskCategory? _categoryFilter;
  TaskPriority? _priorityFilter;
  String _sortBy = 'date-asc';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _taskService.getTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  List<Task> get _filteredTasks {
    final today = DateTime.now().toIso8601String().split('T')[0];

    var result = _tasks.where((task) {
      final matchesSearch = task.title.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchTerm.toLowerCase());

      bool matchesStatus = true;
      if (_statusFilter == 'Completed') {
        matchesStatus = task.completed;
      } else if (_statusFilter == 'Pending') {
        matchesStatus = !task.completed;
      } else if (_statusFilter == 'Overdue') {
        matchesStatus = !task.completed && task.dueDate.compareTo(today) < 0;
      }

      final matchesCategory = _categoryFilter == null || task.category == _categoryFilter;
      final matchesPriority = _priorityFilter == null || task.priority == _priorityFilter;

      return matchesSearch && matchesStatus && matchesCategory && matchesPriority;
    }).toList();

    final priorityWeight = {
      TaskPriority.high: 3,
      TaskPriority.medium: 2,
      TaskPriority.low: 1,
    };

    result.sort((a, b) {
      switch (_sortBy) {
        case 'date-asc':
          return a.dueDate.compareTo(b.dueDate);
        case 'date-desc':
          return b.dueDate.compareTo(a.dueDate);
        case 'priority-high':
          return priorityWeight[b.priority]!.compareTo(priorityWeight[a.priority]!);
        case 'priority-low':
          return priorityWeight[a.priority]!.compareTo(priorityWeight[b.priority]!);
        default:
          return 0;
      }
    });

    return result;
  }

  Future<void> _handleToggleTask(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    await _taskService.updateTask(id, completed: !task.completed);
    await _loadTasks();
  }

  Future<void> _handleDeleteTask(String id) async {
    await _taskService.deleteTask(id);
    await _loadTasks();
  }

  Future<void> _handleFormSubmit({
    required String title,
    required String description,
    required TaskCategory category,
    required TaskPriority priority,
    required String dueDate,
    Reminder? reminder,
  }) async {
    if (_editingTask != null) {
      await _taskService.updateTask(
        _editingTask!.id,
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
        reminder: reminder,
      );
    } else {
      await _taskService.addTask(
        title: title,
        description: description,
        category: category,
        priority: priority,
        dueDate: dueDate,
        reminder: reminder,
      );
    }

    if (!mounted) return;
    setState(() {
      _editingTask = null;
    });

    await _loadTasks();
  }

  void _openEditForm(Task task) {
    setState(() {
      _editingTask = task;
    });
    _showTaskForm();
  }

  static const double _maxContentWidth = 920;

  Widget _centered(double horizontalPadding, Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: child,
        ),
      ),
    );
  }

  Widget _pillChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final bg = Theme.of(context).colorScheme.surfaceContainerHighest;
    final selectedBg = Provider.of<ThemeProvider>(context).accentColorLight;
    final fg = Theme.of(context).colorScheme.onSurface.withOpacity(0.75);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? selectedBg : bg,
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : fg,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.sizeOf(context).width < 720;

    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Provider.of<ThemeProvider>(context).accentColorLight,
                Provider.of<ThemeProvider>(context).accentColorDark,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Colors.white,
                  ),
                ).animate().scale(duration: 2000.ms, curve: Curves.easeInOut).rotate(duration: 2000.ms, curve: Curves.easeInOut),
                const SizedBox(height: 24),
                Text(
                  'TaskFlow',
                  style: GoogleFonts.inter(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Focus on what matters.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 72,
            titleSpacing: 24,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).accentColorLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.list_alt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'TaskFlow',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (!isNarrow) ...[
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildViewTabs(),
                    ),
                  ),
                ] else
                  const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                      themeProvider.setThemeMode(
                        themeProvider.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
                      );
                    },
                    icon: Icon(
                      Provider.of<ThemeProvider>(context).themeMode == ThemeMode.light
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      size: 18,
                    ),
                  ),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Provider.of<ThemeProvider>(context).accentColorLight, width: 2),
                  ),
                  child: const Icon(Icons.person, size: 18),
                ),
              ],
            ),
          ),
          if (isNarrow)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: _centered(24, Align(alignment: Alignment.center, child: _buildViewTabs())),
              ),
            ),
          if (_view == 'list')
            SliverToBoxAdapter(
              child: const SizedBox(height: 24),
            ),
          if (_view == 'list')
            SliverToBoxAdapter(
              child: _centered(24, _buildFiltersSection()),
            ),
          if (_view == 'list')
            SliverToBoxAdapter(
              child: const SizedBox(height: 24),
            ),
          if (_view == 'list' && _filteredTasks.isEmpty)
            SliverToBoxAdapter(
              child: _centered(
                24,
                Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(44),
                          ),
                          child: Icon(
                            Icons.search,
                            size: 34,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'No tasks found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try adjusting your filters or creating a new\n task',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.45),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_view == 'list' && _filteredTasks.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
              sliver: SliverToBoxAdapter(
                child: _centered(
                  0,
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return TaskCard(
                        task: task,
                        onToggle: _handleToggleTask,
                        onDelete: _handleDeleteTask,
                        onEdit: _openEditForm,
                      );
                    },
                  ),
                ),
              ),
            ),
          if (_view == 'dashboard')
            SliverToBoxAdapter(
              child: _centered(
                24,
                FutureBuilder(
                  future: _taskService.getStats(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return StatsDashboard(stats: snapshot.data!);
                    }
                    return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskForm,
        backgroundColor: Provider.of<ThemeProvider>(context).accentColorLight,
        foregroundColor: Colors.white,
        elevation: 10,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showTaskForm() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TaskForm(
        initialTask: _editingTask,
        onSubmit: ({
          required String title,
          required String description,
          required TaskCategory category,
          required TaskPriority priority,
          required String dueDate,
          Reminder? reminder,
        }) {
          Navigator.of(context).pop();
          _handleFormSubmit(
            title: title,
            description: description,
            category: category,
            priority: priority,
            dueDate: dueDate,
            reminder: reminder,
          );
        },
        onClose: () {
          setState(() {
            _editingTask = null;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildViewTabs() {
    final accent = Provider.of<ThemeProvider>(context).accentColorLight;

    Widget tab({
      required String label,
      required IconData icon,
      required bool selected,
      required VoidCallback onTap,
      required BorderRadius radius,
    }) {
      return InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? accent : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? accent : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          tab(
            label: 'List',
            icon: Icons.view_list,
            selected: _view == 'list',
            onTap: () => setState(() => _view = 'list'),
            radius: BorderRadius.circular(8),
          ),
          tab(
            label: 'Dashboard',
            icon: Icons.grid_view,
            selected: _view == 'dashboard',
            onTap: () => setState(() => _view = 'dashboard'),
            radius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    final muted = Theme.of(context).colorScheme.onSurface.withOpacity(0.55);

    Widget sectionLabel(String text) {
      return Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: muted,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackSearchStatus = constraints.maxWidth < 720;

          final search = Container(
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchTerm = value),
              style: GoogleFonts.inter(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: GoogleFonts.inter(color: muted, fontSize: 12),
                prefixIcon: Icon(Icons.search, size: 18, color: muted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          );

          final status = Row(
            children: [
              sectionLabel('STATUS'),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pillChip(
                      label: 'All',
                      selected: _statusFilter == 'All',
                      onTap: () => setState(() => _statusFilter = 'All'),
                    ),
                    _pillChip(
                      label: 'Completed',
                      selected: _statusFilter == 'Completed',
                      onTap: () => setState(() => _statusFilter = 'Completed'),
                    ),
                    _pillChip(
                      label: 'Pending',
                      selected: _statusFilter == 'Pending',
                      onTap: () => setState(() => _statusFilter = 'Pending'),
                    ),
                    _pillChip(
                      label: 'Overdue',
                      selected: _statusFilter == 'Overdue',
                      onTap: () => setState(() => _statusFilter = 'Overdue'),
                    ),
                  ],
                ),
              ),
            ],
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (stackSearchStatus) ...[
                search,
                const SizedBox(height: 12),
                status,
              ] else
                Row(
                  children: [
                    Expanded(flex: 5, child: search),
                    const SizedBox(width: 16),
                    Expanded(flex: 6, child: status),
                  ],
                ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 86, child: sectionLabel('PRIORITY')),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pillChip(
                    label: 'All',
                    selected: _priorityFilter == null,
                    onTap: () => setState(() => _priorityFilter = null),
                  ),
                  _pillChip(
                    label: 'Low',
                    selected: _priorityFilter == TaskPriority.low,
                    onTap: () => setState(() => _priorityFilter = TaskPriority.low),
                  ),
                  _pillChip(
                    label: 'Medium',
                    selected: _priorityFilter == TaskPriority.medium,
                    onTap: () => setState(() => _priorityFilter = TaskPriority.medium),
                  ),
                  _pillChip(
                    label: 'High',
                    selected: _priorityFilter == TaskPriority.high,
                    onTap: () => setState(() => _priorityFilter = TaskPriority.high),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 86, child: sectionLabel('CATEGORY')),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _pillChip(
                    label: 'All',
                    selected: _categoryFilter == null,
                    onTap: () => setState(() => _categoryFilter = null),
                  ),
                  ...TaskCategory.values.map((cat) {
                    return _pillChip(
                      label: cat.displayName,
                      selected: _categoryFilter == cat,
                      onTap: () => setState(() => _categoryFilter = cat),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.swap_vert, size: 14, color: muted),
              const SizedBox(width: 6),
              sectionLabel('SORT'),
              const SizedBox(width: 12),
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _sortBy,
                  underline: const SizedBox(),
                  isDense: true,
                  icon: Icon(Icons.keyboard_arrow_down, size: 18, color: muted),
                  items: const [
                    DropdownMenuItem(value: 'date-asc', child: Text('Due Date (Soonest)')),
                    DropdownMenuItem(value: 'date-desc', child: Text('Due Date (Latest)')),
                    DropdownMenuItem(value: 'priority-high', child: Text('Priority (Highest)')),
                    DropdownMenuItem(value: 'priority-low', child: Text('Priority (Lowest)')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
              ),
            ],
          ),
            ],
          );
        },
      ),
    );
  }
}
