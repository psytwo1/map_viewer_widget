import 'dart:async';

import 'package:flutter_map/plugin_api.dart';

import 'map_rotation_stream_controller_creator.dart';

/// [StreamController] manager class of type [MapRotationStream]
/// This class is a singleton
class MapRotationStreamControllerManager {
  static final _instance = MapRotationStreamControllerManager._();

  factory MapRotationStreamControllerManager() {
    return _instance;
  }

  MapRotationStreamControllerManager._();

  static final Map<MapController, MapRotationStreamControllerCreator>
      mapRotationStreamControllerMap = {};

  static void addMapController(
      {required MapController mapController,
      Duration duration = const Duration(seconds: 1)}) {
    if (!mapRotationStreamControllerMap.containsKey(mapController)) {
      mapRotationStreamControllerMap[mapController] =
          MapRotationStreamControllerCreator(
              mapController: mapController, duration: duration);
    }
  }

  static Stream<double> getMapRotationStream(MapController mapController) {
    return mapRotationStreamControllerMap[mapController]!
        .rotationStreamController
        .stream;
  }

  static void dispose() {
    for (var value in mapRotationStreamControllerMap.values) {
      value.timer.cancel();
    }
  }
}
