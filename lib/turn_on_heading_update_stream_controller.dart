import 'dart:async';

import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'map_viewer_widget_stream_creator.dart';

/// [StreamController] class of type [TurnOnHeadingUpdate]
/// This class is a singleton
class TurnOnHeadingUpdateStreamController
    extends MapViewerWidgetStreamCreator<TurnOnHeadingUpdate> {
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
}
