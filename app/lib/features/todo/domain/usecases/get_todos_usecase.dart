import 'package:app/core/error/failures.dart';
import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';
import 'package:dartz/dartz.dart';

class GetTodosUseCase {
  final TodoRepository repository;
  GetTodosUseCase(this.repository);

  Future<Either<Failure, List<Todo>>> call() {
    return repository.getTodos();
  }
}
