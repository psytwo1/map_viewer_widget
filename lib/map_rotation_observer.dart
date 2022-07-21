import 'package:flutter_map/plugin_api.dart';

class MapRotationObserver {
  static final _instance = MapRotationObserver._(
    mapController: _mapController!,
  );
  MapController mapController;
  static late final MapController? _mapController;

  factory MapRotationObserver({required mapController}) {
    _mapController ??= mapController;
    return _instance;
  }

  // late final Stream<double>? _mapRotateionStream;
  double oldMapRotation = 0;
  MapRotationObserver._({
    required this.mapController,
  });

  // Stream<double>? get mapRotateionStream {
  //   _mapRotateionStream ??=
  //       Stream<double>.periodic(const Duration(seconds: 1), (_) {
  //     if (oldMapRotation != mapController.rotation) {
  //       oldMapRotation = mapController.rotation;
  //     }
  //     return oldMapRotation;
  //   });
  //   return _mapRotateionStream;
  // }
  int _testValue = 0;
  void testFunc() {
    _testValue++;
  }

  int get testValue => _testValue;
}
