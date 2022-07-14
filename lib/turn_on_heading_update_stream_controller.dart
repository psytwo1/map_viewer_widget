import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'map_viewer_widget_stream_factory.dart';

class TurnOnHeadingUpdateStreamController
    extends MapViewerWidgetStreamFactory<TurnOnHeadingUpdate> {
  static final _instance = TurnOnHeadingUpdateStreamController._();

  factory TurnOnHeadingUpdateStreamController() {
    return _instance;
  }

  TurnOnHeadingUpdateStreamController._();

  @override
  StreamController<TurnOnHeadingUpdate> createContoller() =>
      StreamController<TurnOnHeadingUpdate>.broadcast();

  static StreamController<TurnOnHeadingUpdate> get streamController =>
      _instance.sc;

  static Stream<TurnOnHeadingUpdate> get stream => _instance.s;

  // static Stream<NavigationState> get navigationStateStream {
  //   return _streamController.stream;
  // }

  // static final StreamController<CenterOnLocationUpdate>
  //     _centerOnLocationUpdateStreamController =
  //     StreamController<CenterOnLocationUpdate>.broadcast();

  // static StreamController<CenterOnLocationUpdate>
  //     get centerOnLocationUpdateStreamController {
  //   return _centerOnLocationUpdateStreamController;
  // }

  // static Stream<CenterOnLocationUpdate> get centerOnLocationUpdateStream {
  //   return _centerOnLocationUpdateStreamController.stream;
  // }

  // static final StreamController<TurnOnHeadingUpdate>
  //     _turnOnHeadingUpdateStreamController =
  //     StreamController<TurnOnHeadingUpdate>.broadcast();

  // static StreamController<TurnOnHeadingUpdate>
  //     get turnOnHeadingUpdateStreamController {
  //   return _turnOnHeadingUpdateStreamController;
  // }

  // static Stream<TurnOnHeadingUpdate> get turnOnHeadingUpdateStream {
  //   return _turnOnHeadingUpdateStreamController.stream;
  // }
}
