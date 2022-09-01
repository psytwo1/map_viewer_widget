import 'dart:async';

import 'package:flutter_map/plugin_api.dart';

/// MapRotation type StreamController Creator class
class MapRotationStreamControllerCreator {
  final MapController mapController;
  late final StreamController<double> _rotationStreamController;
  double _oldMapRotation = 0;
  late final Timer _timer;

  MapRotationStreamControllerCreator({
    required this.mapController,
    Duration duration = const Duration(seconds: 1),
  }) {
    _rotationStreamController = StreamController<double>.broadcast();
    _timer = Timer.periodic(duration, (timer) {
      if (_oldMapRotation != mapController.rotation) {
        _oldMapRotation = mapController.rotation;
        _rotationStreamController.sink.add(_oldMapRotation);
      }
    });
  }
  Timer get timer => _timer;
  StreamController<double> get rotationStreamController =>
      _rotationStreamController;
}
