import 'dart:async';
import 'package:flutter/foundation.dart';

/// Converts any Stream into a Listenable that go_router can watch.
/// Whenever the stream emits, this notifies listeners -> go_router
/// re-runs its redirect logic.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
