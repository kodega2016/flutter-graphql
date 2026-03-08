import 'package:app/features/auth/presentation/providers/auth_controller.dart';
import 'package:app/features/todo/presentation/providers/todo_controller.dart';
import 'package:app/features/todo/presentation/providers/todo_state.dart';
import 'package:app/features/todo/presentation/widgets/add_todo_dialog.dart';
import 'package:app/features/todo/presentation/widgets/todo_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  Future<void> _showAddTodoDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const AddTodoDialog(),
    );

    if (result == null) return;

    final title = result['title'] ?? '';
    final description = result['description'] ?? '';

    if (title.trim().isEmpty) return;

    await ref
        .read(todoControllerProvider.notifier)
        .addTodo(title: title, description: description);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoState = ref.watch(todoControllerProvider);

    ref.listen<TodoState>(todoControllerProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: todoState.when(
        initial: () => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(message),
          ),
        ),
        loaded: (todos) {
          if (todos.isEmpty) {
            return const Center(child: Text('No todos yet'));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(todoControllerProvider.notifier).loadTodos();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return TodoItem(
                  todo: todo,
                  onToggle: () {
                    ref
                        .read(todoControllerProvider.notifier)
                        .toggleTodo(todo.id);
                  },
                  onDelete: () {
                    ref
                        .read(todoControllerProvider.notifier)
                        .deleteTodo(todo.id);
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
