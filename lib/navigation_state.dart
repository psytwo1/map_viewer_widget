import 'dart:async';

enum NavigationState { northUp, headUp, none }

class NavigationStateManager {
  static final NavigationStateManager _instance = NavigationStateManager._();

  factory NavigationStateManager() {
    return _instance;
  }

  NavigationStateManager._();

  static final StreamController<NavigationState> _streamController =
      StreamController<NavigationState>.broadcast();

  static StreamController<NavigationState> get streamController {
    return _streamController;
  }

  static Stream<NavigationState> get stream {
    return _streamController.stream;
  }
}
