import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'navigation_status.dart';

class MapViewerState {
  MapViewerState(this.navigationStatus) {
    switch (navigationStatus) {
      case NavigationStatus.northUp:
        centerOnLocationUpdate = CenterOnLocationUpdate.always;
        turnOnHeadingUpdate = TurnOnHeadingUpdate.never;
        break;

      case NavigationStatus.headUp:
        centerOnLocationUpdate = CenterOnLocationUpdate.always;
        turnOnHeadingUpdate = TurnOnHeadingUpdate.always;
        break;

      case NavigationStatus.none:
        centerOnLocationUpdate = CenterOnLocationUpdate.never;
        turnOnHeadingUpdate = TurnOnHeadingUpdate.never;
        break;
    }
  }
  final NavigationStatus navigationStatus;
  late final CenterOnLocationUpdate centerOnLocationUpdate;
  late final TurnOnHeadingUpdate turnOnHeadingUpdate;
}
