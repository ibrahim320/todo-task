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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<Task> tasks = [
    Task(id: '1', title: 'Finish Flutter project', createdAt: DateTime.now()),
  ];

  void _addTask(String title) {
    final newTask = Task(
      id: DateTime.now().toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    setState(() {
      tasks.insert(0, newTask);
      _listKey.currentState?.insertItem(0);
    });
  }

  void _editTask(String id, String newTitle) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      setState(() {
        tasks[index].title = newTitle;
      });
    }
  }

  void _deleteTask(String id) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final removedTask = tasks[index];

      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _buildTaskTile(removedTask, animation),
      );

      setState(() {
        tasks.removeAt(index);
      });
    }
  }

  void _toggleTaskCompletion(String id) {
    final index = tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final removedTask = tasks[index];

    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildTaskTile(removedTask, animation),
    );

    setState(() {
      tasks.removeAt(index);
    });

    // Dismiss existing SnackBar before showing a new one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Completed "${removedTask.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              tasks.insert(index, removedTask);
              _listKey.currentState?.insertItem(index);
            });
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTaskTile(Task task, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Task'),
                content:
                    const Text('Are you sure you want to delete this task?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteTask(task.id);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          leading: CupertinoCheckbox(
            value: false,
            onChanged: (_) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do App'),
        centerTitle: true,
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
          : AnimatedList(
              key: _listKey,
              initialItemCount: tasks.length,
              itemBuilder: (context, index, animation) {
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
                    final removedTask = task;
                    final removedIndex = index;

                    _deleteTask(task.id);

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted "${removedTask.title}"'),
                        action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            setState(() {
                              tasks.insert(removedIndex, removedTask);
                              _listKey.currentState?.insertItem(removedIndex);
                            });
                          },
                        ),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: _buildTaskTile(task, animation),
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
