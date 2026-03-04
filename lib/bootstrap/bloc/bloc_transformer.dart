// Global event transformer: controls how events are processed across all blocs.
//
// BlocTransformer is the base for custom transformers (debounce, throttle, etc.)
// that feature packages can define. SequentialBlocTransformer (asyncExpand)
// processes events one at a time, preventing race conditions by default.
// Applied globally in starter.dart via Bloc.transformer.

import 'package:flutter_bloc/flutter_bloc.dart';

/// A function that maps an event of type [Event] to a stream of events.
abstract base class BlocTransformer<Event> {
  /// Transforms the given [stream] of events.
  Stream<Event> transform(Stream<Event> stream, EventMapper<Event> mapper);
}

/// Sequentially maps events to a stream of events.
final class SequentialBlocTransformer<Event> extends BlocTransformer<Event> {
  @override
  Stream<Event> transform(Stream<Event> stream, EventMapper<Event> mapper) =>
      // asyncExpand subscribes to each event stream one at a time —
      // the next event is not processed until the previous one completes.
      // This prevents race conditions caused by concurrent event handling.
      stream.asyncExpand(mapper);
}
