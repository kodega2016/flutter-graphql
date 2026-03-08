import 'package:app/core/error/exceptions.dart';
import 'package:app/features/auth/data/models/auth_payload_model.dart';
import 'package:app/features/auth/data/models/user_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthPayloadModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final GraphQLClient client;
  AuthRemoteDataSourceImpl(this.client);

  static const String _loginMutation = r'''
    mutation Login($email: String!, $password: String!) {
      login(email: $email, password: $password) {
        accessToken
        user {
          id
          email
        }
      }
    }
  ''';

  static const String _meQuery = r'''
    query Me {
      me {
        id
        email
      }
    }
  ''';

  @override
  Future<AuthPayloadModel> login({
    required String email,
    required String password,
  }) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(_loginMutation),
        variables: {'email': email, 'password': password},
      ),
    );

    if (result.hasException) {
      throw AuthException(result.exception.toString());
    }

    final data = result.data?['login'];
    if (data == null) {
      throw AuthException('Login response is empty');
    }

    return AuthPayloadModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> me() async {
    final result = await client.query(
      QueryOptions(
        document: gql(_meQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw AuthException(result.exception.toString());
    }

    final data = result.data?['me'];
    if (data == null) {
      throw AuthException('User not found');
    }
    return UserModel.fromJson(data as Map<String, dynamic>);
  }
}
