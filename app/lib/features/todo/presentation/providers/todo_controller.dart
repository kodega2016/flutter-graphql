import 'dart:async';

import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:app/features/todo/domain/usecases/add_todo_usecase.dart';
import 'package:app/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:app/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:app/features/todo/domain/usecases/subscribe_todo_added_usecase.dart';
import 'package:app/features/todo/domain/usecases/subscribe_todo_deleted_usecase.dart';
import 'package:app/features/todo/domain/usecases/subscribe_todo_updated_usecase.dart';
import 'package:app/features/todo/domain/usecases/toggle_todo_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo_dependencies.dart';
import 'todo_state.dart';

final todoControllerProvider = StateNotifierProvider<TodoController, TodoState>(
  (ref) {
    return TodoController(
      getTodosUseCase: ref.watch(getTodosUseCaseProvider),
      addTodoUseCase: ref.watch(addTodoUseCaseProvider),
      toggleTodoUseCase: ref.watch(toggleTodoUseCaseProvider),
      deleteTodoUseCase: ref.watch(deleteTodoUseCaseProvider),
      subscribeTodoAddedUseCase: ref.watch(subscribeTodoAddedUseCaseProvider),
      subscribeTodoUpdatedUseCase: ref.watch(
        subscribeTodoUpdatedUseCaseProvider,
      ),
      subscribeTodoDeletedUseCase: ref.watch(
        subscribeTodoDeletedUseCaseProvider,
      ),
    );
  },
);

class TodoController extends StateNotifier<TodoState> {
  final GetTodosUseCase getTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final ToggleTodoUseCase toggleTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;
  final SubscribeTodoAddedUseCase subscribeTodoAddedUseCase;
  final SubscribeTodoUpdatedUseCase subscribeTodoUpdatedUseCase;
  final SubscribeTodoDeletedUseCase subscribeTodoDeletedUseCase;

  StreamSubscription<Todo>? _todoAddedSubscription;
  StreamSubscription<Todo>? _todoUpdatedSubscription;
  StreamSubscription<String>? _todoDeletedSubscription;

  TodoController({
    required this.getTodosUseCase,
    required this.addTodoUseCase,
    required this.toggleTodoUseCase,
    required this.deleteTodoUseCase,
    required this.subscribeTodoAddedUseCase,
    required this.subscribeTodoUpdatedUseCase,
    required this.subscribeTodoDeletedUseCase,
  }) : super(const TodoState.initial()) {
    loadTodos();
    _startSubscriptions();
  }

  Future<void> loadTodos() async {
    if (!mounted) return;
    state = const TodoState.loading();

    final result = await getTodosUseCase();
    if (!mounted) return;

    result.fold(
      (failure) {
        if (!mounted) return;
        state = TodoState.error(failure.message);
      },
      (todos) {
        if (!mounted) return;
        state = TodoState.loaded(_sortTodos(todos));
      },
    );
  }

  Future<void> addTodo({
    required String title,
    required String description,
  }) async {
    final currentTodos = state.maybeWhen(
      loaded: (todos) => todos,
      orElse: () => <Todo>[],
    );

    final result = await addTodoUseCase(title: title, description: description);
    if (!mounted) return;

    result.fold(
      (failure) {
        if (!mounted) return;
        state = TodoState.error(failure.message);
        state = TodoState.loaded(currentTodos);
      },
      (todo) {
        if (!mounted) return;

        final exists = currentTodos.any((t) => t.id == todo.id);
        final updatedTodos = exists
            ? currentTodos.map((t) => t.id == todo.id ? todo : t).toList()
            : [todo, ...currentTodos];

        state = TodoState.loaded(_sortTodos(updatedTodos));
      },
    );
  }

  Future<void> toggleTodo(String id) async {
    final currentTodos = state.maybeWhen(
      loaded: (todos) => todos,
      orElse: () => <Todo>[],
    );

    final index = currentTodos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final originalTodo = currentTodos[index];
    final optimisticTodo = originalTodo.copyWith(
      completed: !originalTodo.completed,
    );

    final optimisticTodos = [...currentTodos];
    optimisticTodos[index] = optimisticTodo;

    if (!mounted) return;
    state = TodoState.loaded(_sortTodos(optimisticTodos));

    final result = await toggleTodoUseCase(id: id);
    if (!mounted) return;

    result.fold(
      (failure) {
        if (!mounted) return;
        state = TodoState.loaded(_sortTodos(currentTodos));
      },
      (updatedTodo) {
        if (!mounted) return;

        final updatedTodos = optimisticTodos
            .map((todo) => todo.id == updatedTodo.id ? updatedTodo : todo)
            .toList();

        state = TodoState.loaded(_sortTodos(updatedTodos));
      },
    );
  }

  Future<void> deleteTodo(String id) async {
    final currentTodos = state.maybeWhen(
      loaded: (todos) => todos,
      orElse: () => <Todo>[],
    );

    final updatedTodos = currentTodos
        .where((todo) => todo.id != id)
        .toList(growable: false);

    if (!mounted) return;
    state = TodoState.loaded(_sortTodos(updatedTodos));

    final result = await deleteTodoUseCase(id: id);
    if (!mounted) return;

    result.fold((failure) {
      if (!mounted) return;
      state = TodoState.loaded(_sortTodos(currentTodos));
    }, (_) {});
  }

  void _startSubscriptions() {
    _todoAddedSubscription = subscribeTodoAddedUseCase().listen((todo) {
      final currentTodos = state.maybeWhen(
        loaded: (todos) => todos,
        orElse: () => <Todo>[],
      );

      final exists = currentTodos.any((t) => t.id == todo.id);
      if (exists || !mounted) return;

      state = TodoState.loaded(_sortTodos([todo, ...currentTodos]));
    });

    _todoUpdatedSubscription = subscribeTodoUpdatedUseCase().listen((updated) {
      final currentTodos = state.maybeWhen(
        loaded: (todos) => todos,
        orElse: () => <Todo>[],
      );

      if (!mounted) return;

      final exists = currentTodos.any((t) => t.id == updated.id);
      if (!exists) {
        state = TodoState.loaded(_sortTodos([updated, ...currentTodos]));
        return;
      }

      final nextTodos = currentTodos
          .map((todo) => todo.id == updated.id ? updated : todo)
          .toList();

      state = TodoState.loaded(_sortTodos(nextTodos));
    });

    _todoDeletedSubscription = subscribeTodoDeletedUseCase().listen((
      deletedId,
    ) {
      final currentTodos = state.maybeWhen(
        loaded: (todos) => todos,
        orElse: () => <Todo>[],
      );

      if (!mounted) return;

      final nextTodos = currentTodos
          .where((todo) => todo.id != deletedId)
          .toList();

      state = TodoState.loaded(_sortTodos(nextTodos));
    });
  }

  List<Todo> _sortTodos(List<Todo> todos) {
    final copy = [...todos];
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  @override
  void dispose() {
    _todoAddedSubscription?.cancel();
    _todoUpdatedSubscription?.cancel();
    _todoDeletedSubscription?.cancel();
    super.dispose();
  }
}
