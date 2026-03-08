import 'dart:async';

import 'package:app/features/auth/presentation/providers/auth_controller.dart';
import 'package:app/features/auth/presentation/providers/auth_state.dart';
import 'package:app/features/auth/presentation/screens/login_screen.dart';
import 'package:app/features/todo/presentation/screens/todo_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_paths.dart';

final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final navigatorKey = ref.watch(navigatorKeyProvider);
  final refreshNotifier = RouterRefreshNotifier(ref);

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: RoutePaths.login,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: RoutePaths.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.todos,
        name: 'todos',
        builder: (context, state) => const TodoListScreen(),
      ),
    ],
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final isOnLogin = state.matchedLocation == RoutePaths.login;

      return authState.when(
        initial: () => null,
        loading: () => null,
        authenticated: (_) => isOnLogin ? RoutePaths.todos : null,
        unauthenticated: () => isOnLogin ? null : RoutePaths.login,
        error: (_) => isOnLogin ? null : RoutePaths.login,
      );
    },
  );
});

class RouterRefreshNotifier extends ChangeNotifier {
  RouterRefreshNotifier(this.ref) {
    _removeListener = ref.listen<AuthState>(authControllerProvider, (_, __) {
      scheduleMicrotask(() {
        if (!_disposed) {
          notifyListeners();
        }
      });
    }).close;
  }

  final Ref ref;
  late final void Function() _removeListener;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _removeListener();
    super.dispose();
  }
}
