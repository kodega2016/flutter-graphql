import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';

class SubscribeTodoAddedUseCase {
  final TodoRepository repository;

  SubscribeTodoAddedUseCase(this.repository);

  Stream<Todo> call() {
    return repository.subscribeTodoAdded();
  }
}
