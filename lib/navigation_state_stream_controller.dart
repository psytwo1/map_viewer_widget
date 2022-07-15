import 'dart:async';

import 'map_viewer_widget_stream_factory.dart';
import 'navigation_state.dart';

class NavigationStateStreamController
    extends MapViewerWidgetStreamFactory<NavigationState> {
  static final _instance = NavigationStateStreamController._();

  factory NavigationStateStreamController() {
    return _instance;
  }

  NavigationStateStreamController._();

  @override
  StreamController<NavigationState> createContoller() =>
      StreamController<NavigationState>.broadcast();

  static StreamController<NavigationState> get streamController => _instance.sc;

  static Stream<NavigationState> get stream => _instance.s;
}
