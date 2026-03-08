import 'package:app/core/error/failures.dart';
import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';
import 'package:dartz/dartz.dart';

class ToggleTodoUseCase {
  final TodoRepository repository;

  ToggleTodoUseCase(this.repository);

  Future<Either<Failure, Todo>> call({required String id}) {
    return repository.toggleTodo(id: id);
  }
}
