// Logging of events, transitions, and errors of all BLoC/Cubit

import 'package:flutter_bloc/flutter_bloc.dart';

import 'remove_this_file.dart';

/// [BlocObserver] which logs all bloc state changes, errors and events.
class AppBlocObserver extends BlocObserver {
  /// Creates an instance of [AppBlocObserver] with the provided [logger].
  const AppBlocObserver(this.logger);

  /// Logger used to log information during bloc transitions.
  final Logger logger;

  @override
  void onTransition(
    Bloc<Object?, Object?> bloc,
    Transition<Object?, Object?> transition,
  ) {
    final logMessage = StringBuffer()
      ..writeln('Bloc: ${bloc.runtimeType}')
      ..writeln('Event: ${transition.event.runtimeType}')
      ..writeln(
        'Transition: ${transition.currentState.runtimeType} => '
        '${transition.nextState.runtimeType}',
      )
      ..write('New State: ${transition.nextState?.toString().limit(100)}');

    // TODO: Replace with real logger
    logger.info(logMessage.toString());
    super.onTransition(bloc, transition);
  }

  @override
  void onEvent(Bloc<Object?, Object?> bloc, Object? event) {
    final logMessage = StringBuffer()
      ..writeln('Bloc: ${bloc.runtimeType}')
      ..writeln('Event: ${event.runtimeType}')
      ..write('Details: ${event?.toString().limit(200)}');

    // TODO: Replace with real logger
    logger.info(logMessage.toString());
    super.onEvent(bloc, event);
  }

  @override
  void onError(BlocBase<Object?> bloc, Object error, StackTrace stackTrace) {
    final logMessage = StringBuffer()
      ..writeln('Bloc: ${bloc.runtimeType}')
      ..writeln(error.toString());

    // TODO: Replace with real logger
    logger.error(logMessage.toString(), error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }
}

// TODO: Delete everything below when the logger is actually implemented
extension on String {
  String limit(int maxLength) => length > maxLength ? substring(0, maxLength) : this;
}
