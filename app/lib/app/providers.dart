import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../core/hive/hive_service.dart';
import '../core/network/graphql_auth_holder.dart';
import '../core/network/graphql_client_service.dart';
import '../core/network/network_info.dart';
import '../core/storage/secure_storage_service.dart';

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService(ref.watch(flutterSecureStorageProvider));
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final graphqlAuthHolderProvider = Provider<GraphqlAuthHolder>((ref) {
  return GraphqlAuthHolder();
});

final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final authHolder = ref.watch(graphqlAuthHolderProvider);
  final service = GraphqlClientService(authHolder);
  return service.buildClient();
});
