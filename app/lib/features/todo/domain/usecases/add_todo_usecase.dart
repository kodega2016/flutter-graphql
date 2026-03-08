import 'package:app/core/error/failures.dart';
import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';
import 'package:dartz/dartz.dart';

class AddTodoUseCase {
  final TodoRepository repository;

  AddTodoUseCase(this.repository);

  Future<Either<Failure, Todo>> call({
    required String title,
    required String description,
  }) {
    return repository.addTodo(title: title, description: description);
  }
}
