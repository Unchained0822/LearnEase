import 'package:flutter/material.dart';
import 'task_form.dart';
import 'task_display.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.yellow[800]!,
          secondary: Colors.yellow[800]!,
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow[800],
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.yellow[50],
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Task Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _tasks = [];

  void _addNewTask(String task, DateTime date, String difficulty) {
    setState(() {
      _tasks.add({
        'id': DateTime.now().toString(), // Unique identifier
        'task': task,
        'date': date,
        'difficulty': difficulty,
      });
    });
  }

  void _reorderTasks(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final task = _tasks.removeAt(oldIndex);
      _tasks.insert(newIndex, task);
    });
  }

  Future<void> _navigateToAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Add New Task')),
          body: TaskForm(onAddTask: _addNewTask),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToAddTask,
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        child: _tasks.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt,
                size: 64,
                color: Colors.yellow[800],
              ),
              const SizedBox(height: 16),
              const Text(
                'No tasks yet',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _navigateToAddTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[800],
                  foregroundColor: Colors.black87,
                ),
                child: const Text('Add First Task'),
              ),
            ],
          ),
        )
            : TaskDisplay(tasks: _tasks, onReorder: _reorderTasks),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[800],
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}