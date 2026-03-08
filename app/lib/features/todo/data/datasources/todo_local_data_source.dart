import 'package:app/core/error/exceptions.dart';
import 'package:app/features/todo/data/models/todo_model.dart';
import 'package:hive/hive.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> addOrUpdateTodo(TodoModel todo);
  Future<void> deleteTodo(String id);
  Future<void> clearTodos();
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Box<TodoModel> box;
  const TodoLocalDataSourceImpl(this.box);

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to load cached todos: $e');
    }
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    try {
      await box.clear();
      for (final todo in todos) {
        await box.put(todo.id, todo);
      }
    } catch (e) {
      throw CacheException('Failed to cache todos: $e');
    }
  }

  @override
  Future<void> addOrUpdateTodo(TodoModel todo) async {
    try {
      await box.put(todo.id, todo);
    } catch (e) {
      throw CacheException('Failed to save todo locally: $e');
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await box.delete(id);
    } catch (e) {
      throw CacheException('Failed to delete cached todo: $e');
    }
  }

  @override
  Future<void> clearTodos() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear cached todos: $e');
    }
  }
}
