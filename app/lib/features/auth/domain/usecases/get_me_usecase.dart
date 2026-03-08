import 'package:app/core/error/failures.dart';
import 'package:app/features/auth/domain/entities/user.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetMeUseCase {
  final AuthRepository repository;
  const GetMeUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.me();
  }
}
