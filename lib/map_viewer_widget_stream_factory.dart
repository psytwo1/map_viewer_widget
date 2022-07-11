import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'navigation_state.dart';

abstract class MapViewerWidgetStreamFactory {
  // static late final MapViewerWidgetStreamFactory _instance;

  // factory MapViewerWidgetStreamFactory() {
  //   return _instance;
  // }

  // MapViewerWidgetStreamFactory._();

  StreamController<T> getContoller<T>();

  late final StreamController _streamController;

  StreamController get streamController {
    return _streamController;
  }

  Stream get stream {
    return _streamController.stream;
  }
}
