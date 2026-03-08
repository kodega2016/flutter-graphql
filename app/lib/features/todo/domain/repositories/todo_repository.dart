import 'package:app/core/error/failures.dart';
import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:dartz/dartz.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos();
  Future<Either<Failure, Todo>> addTodo({
    required String title,
    required String description,
  });

  Future<Either<Failure, Todo>> toggleTodo({required String id});
  Future<Either<Failure, Unit>> deleteTodo({required String id});

  Stream<Todo> subscribeTodoAdded();
  Stream<Todo> subscribeTodoUpdated();
  Stream<String> subscribeTodoDeleted();
}
