import 'package:app/app/providers.dart';
import 'package:app/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:app/features/todo/data/datasources/todo_remote_data_source.dart';
import 'package:app/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';
import 'package:app/features/todo/domain/usecases/add_todo_usecase.dart';
import 'package:app/features/todo/domain/usecases/delete_todo_usecase.dart';
import 'package:app/features/todo/domain/usecases/get_todos_usecase.dart';
import 'package:app/features/todo/domain/usecases/subscribe_todo_added_usecase.dart';
import 'package:app/features/todo/domain/usecases/subscribe_todo_deleted_usecase.dart';
import 'package:app/features/todo/domain/usecases/subscribe_todo_updated_usecase.dart';
import 'package:app/features/todo/domain/usecases/toggle_todo_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return TodoLocalDataSourceImpl(hiveService.todosBox);
});

final todoRemoteDataSourceProvider = Provider<TodoRemoteDataSource>((ref) {
  return TodoRemoteDataSourceImpl(ref.watch(graphQLClientProvider));
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl(
    remoteDataSource: ref.watch(todoRemoteDataSourceProvider),
    localDataSource: ref.watch(todoLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getTodosUseCaseProvider = Provider<GetTodosUseCase>((ref) {
  return GetTodosUseCase(ref.watch(todoRepositoryProvider));
});

final addTodoUseCaseProvider = Provider<AddTodoUseCase>((ref) {
  return AddTodoUseCase(ref.watch(todoRepositoryProvider));
});

final toggleTodoUseCaseProvider = Provider<ToggleTodoUseCase>((ref) {
  return ToggleTodoUseCase(ref.watch(todoRepositoryProvider));
});

final deleteTodoUseCaseProvider = Provider<DeleteTodoUseCase>((ref) {
  return DeleteTodoUseCase(ref.watch(todoRepositoryProvider));
});

final subscribeTodoAddedUseCaseProvider = Provider<SubscribeTodoAddedUseCase>((
  ref,
) {
  return SubscribeTodoAddedUseCase(ref.watch(todoRepositoryProvider));
});

final subscribeTodoUpdatedUseCaseProvider =
    Provider<SubscribeTodoUpdatedUseCase>((ref) {
      return SubscribeTodoUpdatedUseCase(ref.watch(todoRepositoryProvider));
    });

final subscribeTodoDeletedUseCaseProvider =
    Provider<SubscribeTodoDeletedUseCase>((ref) {
      return SubscribeTodoDeletedUseCase(ref.watch(todoRepositoryProvider));
    });
