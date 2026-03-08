import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_auth_holder.dart';

class GraphqlClientService {
  final GraphqlAuthHolder authHolder;
  GraphqlClientService(this.authHolder);

  GraphQLClient buildClient() {
    final httpLink = HttpLink('http://localhost:4000/graphql');
    final authLink = AuthLink(
      getToken: () async {
        final token = authHolder.accessToken;
        if (token == null || token.isEmpty) return null;
        return 'Bearer $token';
      },
    );

    final webSocketLink = WebSocketLink(
      'ws://localhost:4000/graphql',
      config: SocketClientConfig(
        autoReconnect: true,
        initialPayload: () async {
          final token = authHolder.accessToken;
          if (token == null || token.isEmpty) {
            return {};
          }

          return {'Authorization': 'Bearer $token'};
        },
      ),
    );

    final link = Link.split(
      (request) => request.isSubscription,
      webSocketLink,
      authLink.concat(httpLink),
    );

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }
}
