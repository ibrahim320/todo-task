import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/task.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Task> tasks = [
    Task(id: '1', title: 'Buy groceries', createdAt: DateTime.now()),
    Task(id: '2', title: 'Walk the dog', createdAt: DateTime.now()),
    Task(id: '3', title: 'Finish Flutter project', createdAt: DateTime.now()),
  ];

  void _addTask(String title) {
    setState(() {
      tasks.add(
        Task(
          id: DateTime.now().toString(),
          title: title,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  void _editTask(String id, String newTitle) {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        tasks[index].title = newTitle;
      }
    });
  }

  void _toggleTaskCompletion(String id) {
    setState(() {
      final index = tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        tasks[index].isCompleted = !tasks[index].isCompleted;
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      tasks.removeWhere((task) => task.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cute To-Do'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newTaskTitle = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddTaskScreen(),
                ),
              );
              if (newTaskTitle != null && newTaskTitle.isNotEmpty) {
                _addTask(newTaskTitle);
              }
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty.png',
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No tasks yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteTask(task.id);
                  },
                  child: Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CupertinoCheckbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          _toggleTaskCompletion(task.id);
                        },
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: task.isCompleted ? Colors.grey : Colors.black,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () async {
                          final editedTitle = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTaskScreen(
                                initialTitle: task.title,
                              ),
                            ),
                          );
                          if (editedTitle != null && editedTitle.isNotEmpty) {
                            _editTask(task.id, editedTitle);
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTaskTitle = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
          if (newTaskTitle != null && newTaskTitle.isNotEmpty) {
            _addTask(newTaskTitle);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
