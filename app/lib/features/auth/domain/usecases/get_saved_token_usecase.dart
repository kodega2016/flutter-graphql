import 'package:app/core/error/failures.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class GetSavedTokenUseCase {
  final AuthRepository repository;
  const GetSavedTokenUseCase(this.repository);

  Future<Either<Failure, String?>> call() {
    return repository.getSavedToken();
  }
}
