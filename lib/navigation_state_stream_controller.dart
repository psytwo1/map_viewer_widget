import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'map_viewer_widget_stream_factory.dart';
import 'navigation_state.dart';

class NavigationStateStreamController extends MapViewerWidgetStreamFactory {
  static final _instance = NavigationStateStreamController._();

  factory NavigationStateStreamController() {
    return _instance;
  }

  NavigationStateStreamController._();

  @override
  StreamController<NavigationState> getContoller<NavigationState>() {
    _streamController = StreamController<NavigationState>();
    return _streamController;
  }

  static late final StreamController<NavigationState> _streamController =
      _instance.getContoller();

  // static StreamController<NavigationState> get streamController {
  //   return _streamController;
  // }

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
