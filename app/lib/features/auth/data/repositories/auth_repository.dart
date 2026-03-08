import 'package:app/core/error/failures.dart';
import 'package:app/core/network/graphql_auth_holder.dart';
import 'package:app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final GraphqlAuthHolder authHolder;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.authHolder,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final payload = await remoteDataSource.login(
        email: email,
        password: password,
      );

      await localDataSource.saveAccessToken(payload.accessToken);
      authHolder.setAccessToken(payload.accessToken);
      return Right(payload.user.toEntity());
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> me() async {
    try {
      final user = await remoteDataSource.me();
      return Right(user.toEntity());
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String?>> getSavedToken() async {
    try {
      final token = await localDataSource.getSavedToken();
      authHolder.setAccessToken(token);
      return Right(token);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await localDataSource.clearAccessToken();
      authHolder.clear();
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
