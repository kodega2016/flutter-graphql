import 'package:app/features/todo/domain/repositories/todo_repository.dart';

class SubscribeTodoDeletedUseCase {
  final TodoRepository repository;

  SubscribeTodoDeletedUseCase(this.repository);

  Stream<String> call() {
    return repository.subscribeTodoDeleted();
  }
}
