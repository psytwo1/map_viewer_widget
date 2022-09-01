import 'dart:async';

import 'map_viewer_widget_stream_creator.dart';
import 'navigation_status.dart';

/// [StreamController] class of type [NavigationStatus]
/// This class is a singleton
class NavigationStatatusStreamController
    extends MapViewerWidgetStreamCreator<NavigationStatus> {
  static final _instance = NavigationStatatusStreamController._();

  factory NavigationStatatusStreamController() {
    return _instance;
  }

  NavigationStatatusStreamController._();

  @override
  StreamController<NavigationStatus> createContoller() =>
      StreamController<NavigationStatus>.broadcast();

  static StreamController<NavigationStatus> get streamController =>
      _instance.sc;

  static Stream<NavigationStatus> get stream => _instance.s;
}
