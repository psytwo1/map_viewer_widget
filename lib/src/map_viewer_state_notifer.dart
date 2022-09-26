import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'map_viewer_state.dart';
import 'navigation_status.dart';

class MapViewerStateNotifer extends StateNotifier<MapViewerState> {
  MapViewerStateNotifer({
    NavigationStatus navigationStatus = NavigationStatus.northUp,
    // required this.mapController,
  }) : super(MapViewerState(NavigationStatus.northUp)) {
    centerCurrentLocationStreamController = StreamController<double>();
    turnHeadingUpLocationStreamController = StreamController<void>();
    setNavigationStatus(
      navigationStatus: navigationStatus,
    );
  }
  // final MapController mapController;
  late final StreamController<double> centerCurrentLocationStreamController;
  late final StreamController<void> turnHeadingUpLocationStreamController;

  void setNavigationStatus({
    required NavigationStatus navigationStatus,
    MapController? mapController,
  }) {
    state = MapViewerState(navigationStatus);

    switch (navigationStatus) {
      case NavigationStatus.northUp:
        centerCurrentLocationStreamController.sink.add(17);
        if (mapController != null) {
          mapController.rotate(0);
        }
        break;

      case NavigationStatus.headUp:
        centerCurrentLocationStreamController.sink.add(17);
        turnHeadingUpLocationStreamController.sink.add(null);
        break;

      case NavigationStatus.none:
        break;
    }
  }

  @override
  void dispose() {
    centerCurrentLocationStreamController.close();
    turnHeadingUpLocationStreamController.close();
    super.dispose();
  }
}
