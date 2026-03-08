import 'package:app/core/error/failures.dart';
import 'package:app/core/network/network_info.dart';
import 'package:app/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:app/features/todo/data/datasources/todo_remote_data_source.dart';
import 'package:app/features/todo/data/models/todo_model.dart';
import 'package:app/features/todo/domain/entities/todo.dart';
import 'package:app/features/todo/domain/repositories/todo_repository.dart';
import 'package:dartz/dartz.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource remoteDataSource;
  final TodoLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  TodoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Todo>>> getTodos() async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        final remoteTodos = await remoteDataSource.getTodos();
        await localDataSource.cacheTodos(remoteTodos);
        return Right(remoteTodos.map((e) => e.toEntity()).toList());
      }

      final cachedTodos = await localDataSource.getCachedTodos();
      return Right(cachedTodos.map((e) => e.toEntity()).toList());
    } catch (e) {
      try {
        final cachedTodos = await localDataSource.getCachedTodos();
        return Right(cachedTodos.map((e) => e.toEntity()).toList());
      } catch (cacheError) {
        return Left(ServerFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Todo>> addTodo({
    required String title,
    required String description,
  }) async {
    try {
      final todo = await remoteDataSource.addTodo(
        title: title,
        description: description,
      );

      await localDataSource.addOrUpdateTodo(todo);

      return Right(todo.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> toggleTodo({required String id}) async {
    try {
      final todo = await remoteDataSource.toggleTodo(id: id);
      await localDataSource.addOrUpdateTodo(todo);
      return Right(todo.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTodo({required String id}) async {
    try {
      await remoteDataSource.deleteTodo(id: id);
      await localDataSource.deleteTodo(id);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Todo> subscribeTodoAdded() {
    return remoteDataSource.subscribeTodoAdded().asyncMap((todoModel) async {
      await localDataSource.addOrUpdateTodo(todoModel);
      return todoModel.toEntity();
    });
  }

  @override
  Stream<Todo> subscribeTodoUpdated() {
    return remoteDataSource.subscribeTodoUpdated().asyncMap((todoModel) async {
      await localDataSource.addOrUpdateTodo(todoModel);
      return todoModel.toEntity();
    });
  }

  @override
  Stream<String> subscribeTodoDeleted() {
    return remoteDataSource.subscribeTodoDeleted().asyncMap((id) async {
      await localDataSource.deleteTodo(id);
      return id;
    });
  }
}
