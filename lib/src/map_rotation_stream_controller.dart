import 'dart:async';

import 'package:flutter_map/plugin_api.dart';

/// MapRotation type StreamController Creator class
class MapRotationStreamController {
  /// constructor
  /// Specify [MapController]
  /// Specify [Duration]
  MapRotationStreamController({
    required this.mapController,
    Duration duration = const Duration(seconds: 1),
  }) {
    _timer = Timer.periodic(duration, (_) {
      if (_currentMapRotation != mapController.rotation) {
        _currentMapRotation = mapController.rotation;
        _rotationStreamController.sink.add(_currentMapRotation);
      }
    });
  }

  final MapController mapController;
  final StreamController<double> _rotationStreamController =
      StreamController<double>();
  late final Timer _timer;
  double _currentMapRotation = 0;

  StreamController<double> get rotationStreamController =>
      _rotationStreamController;

  /// [dispose] instance
  void dispose() {
    _timer.cancel();
    _rotationStreamController.close();
  }
}
