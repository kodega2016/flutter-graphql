import 'package:app/core/error/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> me();
  Future<Either<Failure, String?>> getSavedToken();
  Future<Either<Failure, Unit>> logout();
}
