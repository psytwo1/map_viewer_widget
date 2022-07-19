import 'package:flutter_map/plugin_api.dart';

class MapRotationObserver {
  static final _instance = MapRotationObserver._(
      // mapController: mapController,
      );
  final MapController mapController;
  factory MapRotationObserver({required mapController}) {
    // _mapController = mapController;
    return _instance;
  }

  MapRotationObserver._(
      //   {
      //   required this.mapController,
      // }
      );
}

main() {
  final mro = MapRotationObserver(mapController: MapController());
}

class Aaaa {
  final int initValue;
  Aaaa(this.initValue);
}
