import 'package:app/core/error/failures.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';
import 'package:dartz/dartz.dart';

class DeleteTodoUseCase {
  final TodoRepository repository;

  DeleteTodoUseCase(this.repository);

  Future<Either<Failure, Unit>> call({required String id}) {
    return repository.deleteTodo(id: id);
  }
}
