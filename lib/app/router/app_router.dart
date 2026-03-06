import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nota/app/dependency_container.dart';
import 'package:nota/app/dependency_scope.dart';
import 'package:nota/app/router/app_routes.dart';
import 'package:nota/app/screens/playground_screen.dart';

GoRouter buildRouter({required DependenciesContainer dependencies}) {
  // TODO: remove debug logging before release
  dependencies.logger.debug('buildRouter: GoRouter created');

  return GoRouter(
    initialLocation: AppRoutes.notes,
    routes: [
      GoRoute(
        path: AppRoutes.notes,
        builder: (context, state) {
          // TODO: remove debug logging before release
          dependencies.logger.debug('route: ${state.uri}');
          return const PlaygroundScreen();
        },
        routes: [
          GoRoute(
            path: 'new',
            builder: (context, state) {
              // TODO: remove debug logging before release
              DependenciesScope.of(context).logger.debug('route: ${state.uri}');
              return const _StubScreen(title: 'New Note');
            },
          ),
          GoRoute(
            path: ':id',
            builder: (context, state) {
              // TODO: remove debug logging before release
              dependencies.logger.debug('route: ${state.uri}');
              return _StubScreen(
                title: 'Note #${state.pathParameters['id']}',
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          // TODO: remove debug logging before release
          dependencies.logger.debug('route: ${state.uri}');
          return const _StubScreen(title: 'Settings');
        },
      ),
    ],
  );
}

class _StubScreen extends StatelessWidget {
  const _StubScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
