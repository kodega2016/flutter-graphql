import 'package:app/core/error/exceptions.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();

  Future<TodoModel> addTodo({
    required String title,
    required String description,
  });

  Future<TodoModel> toggleTodo({required String id});
  Future<void> deleteTodo({required String id});

  Stream<TodoModel> subscribeTodoAdded();
  Stream<TodoModel> subscribeTodoUpdated();
  Stream<String> subscribeTodoDeleted();
}

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final GraphQLClient client;
  TodoRemoteDataSourceImpl(this.client);

  static const String _getTodosQuery = r'''
    query GetTodos {
      todos {
        id
        title
        description
        completed
        createdAt
        ownerId
      }
    }
  ''';

  static const String _addTodoMutation = r'''
    mutation AddTodo($title: String!, $description: String!) {
      addTodo(title: $title, description: $description) {
        id
        title
        description
        completed
        createdAt
        ownerId
      }
    }
  ''';

  static const String _toggleTodoMutation = r'''
    mutation ToggleTodo($id: ID!) {
      toggleTodo(id: $id) {
        id
        title
        description
        completed
        createdAt
        ownerId
      }
    }
  ''';

  static const String _deleteTodoMutation = r'''
    mutation DeleteTodo($id: ID!) {
      deleteTodo(id: $id)
    }
  ''';

  static const String _todoAddedSubscription = r'''
    subscription OnTodoAdded {
      todoAdded {
        id
        title
        description
        completed
        createdAt
        ownerId
      }
    }
  ''';

  static const String _todoUpdatedSubscription = r'''
    subscription OnTodoUpdated {
      todoUpdated {
        id
        title
        description
        completed
        createdAt
        ownerId
      }
    }
  ''';

  static const String _todoDeletedSubscription = r'''
    subscription OnTodoDeleted {
      todoDeleted
    }
  ''';

  @override
  Future<List<TodoModel>> getTodos() async {
    final result = await client.query(
      QueryOptions(
        document: gql(_getTodosQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw AppServerException(result.exception.toString());
    }

    final rawTodos = result.data?['todos'] as List<dynamic>?;
    if (rawTodos == null) {
      return [];
    }

    return rawTodos
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TodoModel> addTodo({
    required String title,
    required String description,
  }) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(_addTodoMutation),
        variables: {'title': title, 'description': description},
      ),
    );

    if (result.hasException) {
      throw AppServerException(result.exception.toString());
    }

    final data = result.data?['addTodo'];
    if (data == null) {
      throw AppServerException('Add todo response is empty');
    }

    return TodoModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<TodoModel> toggleTodo({required String id}) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(_toggleTodoMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw AppServerException(result.exception.toString());
    }

    final data = result.data?['toggleTodo'];
    if (data == null) {
      throw AppServerException('Toggle todo response is empty');
    }

    return TodoModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTodo({required String id}) async {
    final result = await client.mutate(
      MutationOptions(
        document: gql(_deleteTodoMutation),
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw AppServerException(result.exception.toString());
    }

    final success = result.data?['deleteTodo'] as bool?;
    if (success != true) {
      throw AppServerException('Failed to delete todo');
    }
  }

  @override
  Stream<TodoModel> subscribeTodoAdded() {
    return client
        .subscribe(SubscriptionOptions(document: gql(_todoAddedSubscription)))
        .map((result) {
          if (result.hasException) {
            throw AppServerException(result.exception.toString());
          }

          final data = result.data?['todoAdded'];
          if (data == null) {
            throw AppServerException('todoAdded payload is empty');
          }

          return TodoModel.fromJson(data as Map<String, dynamic>);
        });
  }

  @override
  Stream<TodoModel> subscribeTodoUpdated() {
    return client
        .subscribe(SubscriptionOptions(document: gql(_todoUpdatedSubscription)))
        .map((result) {
          if (result.hasException) {
            throw AppServerException(result.exception.toString());
          }

          final data = result.data?['todoUpdated'];
          if (data == null) {
            throw AppServerException('todoUpdated payload is empty');
          }

          return TodoModel.fromJson(data as Map<String, dynamic>);
        });
  }

  @override
  Stream<String> subscribeTodoDeleted() {
    return client
        .subscribe(SubscriptionOptions(document: gql(_todoDeletedSubscription)))
        .map((result) {
          if (result.hasException) {
            throw AppServerException(result.exception.toString());
          }

          final data = result.data?['todoDeleted'];
          if (data == null) {
            throw AppServerException('todoDeleted payload is empty');
          }

          return data as String;
        });
  }
}
