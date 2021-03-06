import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'map_viewer_widget_stream_factory.dart';

class CenterOnLocationUpdateStreamController
    extends MapViewerWidgetStreamFactory<CenterOnLocationUpdate> {
  static final _instance = CenterOnLocationUpdateStreamController._();

  factory CenterOnLocationUpdateStreamController() {
    return _instance;
  }

  CenterOnLocationUpdateStreamController._();

  @override
  StreamController<CenterOnLocationUpdate> createContoller() =>
      StreamController<CenterOnLocationUpdate>.broadcast();

  static StreamController<CenterOnLocationUpdate> get streamController =>
      _instance.sc;

  static Stream<CenterOnLocationUpdate> get stream => _instance.s;
}
