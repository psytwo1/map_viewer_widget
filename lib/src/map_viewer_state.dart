import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'navigation_status.dart';

class MapViewerState {
  MapViewerState(this.navigationStatus) {
    switch (navigationStatus) {
      case NavigationStatus.northUp:
        centerOnLocationUpdate = FollowOnLocationUpdate.always;
        turnOnHeadingUpdate = TurnOnHeadingUpdate.never;
        break;

      case NavigationStatus.headUp:
        centerOnLocationUpdate = FollowOnLocationUpdate.always;
        turnOnHeadingUpdate = TurnOnHeadingUpdate.always;
        break;

      case NavigationStatus.none:
        centerOnLocationUpdate = FollowOnLocationUpdate.never;
        turnOnHeadingUpdate = TurnOnHeadingUpdate.never;
        break;
    }
  }
  final NavigationStatus navigationStatus;
  late final FollowOnLocationUpdate centerOnLocationUpdate;
  late final TurnOnHeadingUpdate turnOnHeadingUpdate;
}
