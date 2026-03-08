import 'package:app/app/providers.dart';
import 'package:app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:app/features/auth/data/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/repositories/auth_repository.dart';
import 'package:app/features/auth/domain/usecases/get_me_usecase.dart';
import 'package:app/features/auth/domain/usecases/get_saved_token_usecase.dart';
import 'package:app/features/auth/domain/usecases/login_usecase.dart';
import 'package:app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_state.dart';

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.watch(secureStorageServiceProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(graphQLClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    authHolder: ref.watch(graphqlAuthHolderProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final getSavedTokenUseCaseProvider = Provider<GetSavedTokenUseCase>((ref) {
  return GetSavedTokenUseCase(ref.watch(authRepositoryProvider));
});

final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  return GetMeUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      ref: ref,
      loginUseCase: ref.watch(loginUseCaseProvider),
      getSavedTokenUseCase: ref.watch(getSavedTokenUseCaseProvider),
      getMeUseCase: ref.watch(getMeUseCaseProvider),
      logoutUseCase: ref.watch(logoutUseCaseProvider),
    );
  },
);

class AuthController extends StateNotifier<AuthState> {
  final Ref ref;
  final LoginUseCase loginUseCase;
  final GetSavedTokenUseCase getSavedTokenUseCase;
  final GetMeUseCase getMeUseCase;
  final LogoutUseCase logoutUseCase;

  AuthController({
    required this.ref,
    required this.loginUseCase,
    required this.getSavedTokenUseCase,
    required this.getMeUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState.initial()) {
    _init();
  }

  Future<void> _init() async {
    await checkAuth();
  }

  Future<void> checkAuth() async {
    if (!mounted) return;
    state = const AuthState.loading();

    final savedTokenResult = await getSavedTokenUseCase();
    if (!mounted) return;

    await savedTokenResult.fold(
      (failure) async {
        if (!mounted) return;
        state = const AuthState.unauthenticated();
      },
      (token) async {
        if (!mounted) return;

        if (token == null || token.isEmpty) {
          state = const AuthState.unauthenticated();
          return;
        }

        final meResult = await getMeUseCase();
        if (!mounted) return;

        await meResult.fold(
          (failure) async {
            await logoutUseCase();
            if (!mounted) return;
            state = const AuthState.unauthenticated();
          },
          (user) async {
            if (!mounted) return;
            state = AuthState.authenticated(user);
          },
        );
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    if (!mounted) return;
    state = const AuthState.loading();

    final result = await loginUseCase(email: email, password: password);
    if (!mounted) return;

    result.fold(
      (failure) {
        if (!mounted) return;
        state = AuthState.error(failure.message);
      },
      (user) {
        if (!mounted) return;
        ref.invalidate(graphQLClientProvider);
        state = AuthState.authenticated(user);
      },
    );
  }

  Future<void> logout() async {
    if (!mounted) return;
    state = const AuthState.loading();

    final result = await logoutUseCase();
    if (!mounted) return;

    result.fold(
      (failure) {
        if (!mounted) return;
        state = AuthState.error(failure.message);
      },
      (_) {
        if (!mounted) return;
        ref.invalidate(graphQLClientProvider);
        state = const AuthState.unauthenticated();
      },
    );
  }
}
