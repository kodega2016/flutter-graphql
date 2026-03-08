import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';

class SubscribeTodoUpdatedUseCase {
  final TodoRepository repository;

  SubscribeTodoUpdatedUseCase(this.repository);

  Stream<Todo> call() {
    return repository.subscribeTodoUpdated();
  }
}
