import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:map_viewer_widget/src/map_options_ext.dart';
import 'package:stream_transform/stream_transform.dart';

import 'compass_button_display.dart';
import 'compass_button_widget.dart';
import 'icon_with_background.dart';
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

final mapViewerStateNotiferProvider =
    StateNotifierProvider.autoDispose<MapViewerStateNotifer, MapViewerState>(
  (ref) {
    final stateNotifer = MapViewerStateNotifer();
    ref.onDispose(stateNotifer.dispose);
    return stateNotifer;
  },
);

/// MapViewerWidget is map viewer widget
class MapViewerWidget extends StatelessWidget {
  /// A constructor of `MapViewerWidget` class.
  const MapViewerWidget({
    super.key,
    required this.children,
    required this.options,
    this.navigationButtonVisible = true,
    this.compassButtonDisplay = CompassButtonDisplay.auto,
    this.defaultCenterOnLocationUpdate = CenterOnLocationUpdate.always,
    this.defaultTurnOnHeadingUpdate = TurnOnHeadingUpdate.never,
    this.defaultNavigationStatus = NavigationStatus.northUp,
    this.mapController,
  });

  /// A set of layers' widgets to used to create the layers on the map.
  final List<Widget> children;

  /// [MapOptions] to create a MapState with.
  ///
  /// This property must not be null.
  final MapOptions options;

  /// Visibility of navigation buttons
  final bool navigationButtonVisible;

  /// Compass button display mode
  /// Default value is auto
  /// See [CompassButtonDisplay] for details
  final CompassButtonDisplay compassButtonDisplay;

  /// Default Center On Location Update
  final CenterOnLocationUpdate defaultCenterOnLocationUpdate;

  /// Default Turn On Heading Update
  final TurnOnHeadingUpdate defaultTurnOnHeadingUpdate;

  /// Default Navigation Status
  /// See [NavigationStatus] for details
  final NavigationStatus defaultNavigationStatus;

  /// Specified when using [MapController] from outside the class
  final MapController? mapController;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MapViewerWidgetBody(
        options: options,
        navigationButtonVisible: navigationButtonVisible,
        compassButtonDisplay: compassButtonDisplay,
        mapController: mapController,
        children: children,
      ),
    );
  }
}

/// [MapViewerWidgetBody] is the body of the [MapViewerWidget].
class MapViewerWidgetBody extends StatelessWidget {
  MapViewerWidgetBody({
    super.key,
    required this.children,
    required this.options,
    this.navigationButtonVisible = true,
    this.compassButtonDisplay = CompassButtonDisplay.auto,
    this.mapController,
  });

  /// A set of layers' widgets to used to create the layers on the map.
  final List<Widget> children;

  /// [MapOptions] to create a MapState with.
  ///
  /// This property must not be null.
  final MapOptions options;

  /// Visibility of navigation buttons
  final bool navigationButtonVisible;

  /// Compass button display mode
  /// Default value is auto
  /// See [CompassButtonDisplay] for details
  final CompassButtonDisplay compassButtonDisplay;

  /// Specified when using [MapController] from outside the class
  final MapController? mapController;
  late final MapController _mapController = mapController ?? MapController();

  final IconWithBackground nearMeWhite = const IconWithBackground(
    bgColor: Colors.blue,
    icon: Icon(
      Icons.near_me,
      color: Colors.white,
    ),
  );
  final IconWithBackground nearMeBlue = const IconWithBackground(
    bgColor: Colors.white,
    icon: Icon(
      Icons.near_me,
      color: Colors.blue,
    ),
  );
  final IconWithBackground navigationWhite = const IconWithBackground(
    bgColor: Colors.blue,
    icon: Icon(Icons.navigation, color: Colors.white),
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer(
          builder: (context, ref, child) {
            return FlutterMap(
              mapController: _mapController,
              options: options.copyWith(
                onPositionChanged: options.onPositionChanged ??
                    (MapPosition position, bool hasGesture) {
                      final navigationStatus = ref
                          .read(mapViewerStateNotiferProvider)
                          .navigationStatus;
                      if (hasGesture &&
                          navigationStatus != NavigationStatus.none) {
                        ref
                            .read(mapViewerStateNotiferProvider.notifier)
                            .setNavigationStatus(
                              navigationStatus: NavigationStatus.none,
                              mapController: _mapController,
                            );
                      }
                    },
              ),
              children: children.followedBy([
                FutureBuilder(
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return Consumer(
                        builder: (context, ref, child) {
                          return LocationMarkerLayerWidget(
                            plugin: LocationMarkerPlugin(
                              centerCurrentLocationStream: ref
                                  .watch(
                                    mapViewerStateNotiferProvider.notifier,
                                  )
                                  .centerCurrentLocationStreamController
                                  .stream,
                              centerOnLocationUpdate: ref
                                  .watch(mapViewerStateNotiferProvider)
                                  .centerOnLocationUpdate,
                              turnOnHeadingUpdate: ref
                                  .watch(mapViewerStateNotiferProvider)
                                  .turnOnHeadingUpdate,
                              turnHeadingUpLocationStream: ref
                                  .watch(mapViewerStateNotiferProvider.notifier)
                                  .turnHeadingUpLocationStreamController
                                  .stream,
                            ),
                            options: LocationMarkerLayerOptions(),
                          );
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                  future: _isPermitted(),
                ),
              ]).toList(),
            );
          },
        ),
        if (navigationButtonVisible)
          Consumer(
            builder: (context, ref, child) {
              return Positioned(
                right: 20,
                bottom: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    final navigationStatus = ref
                        .read(mapViewerStateNotiferProvider)
                        .navigationStatus;
                    if (navigationStatus == NavigationStatus.northUp) {
                      ref
                          .read(mapViewerStateNotiferProvider.notifier)
                          .setNavigationStatus(
                            navigationStatus: NavigationStatus.headUp,
                            mapController: _mapController,
                          );
                    } else {
                      ref
                          .read(mapViewerStateNotiferProvider.notifier)
                          .setNavigationStatus(
                            navigationStatus: NavigationStatus.northUp,
                            mapController: _mapController,
                          );
                    }
                  },
                  backgroundColor: _getNavigationIcon(
                    ref.watch(mapViewerStateNotiferProvider).navigationStatus,
                  ).bgColor,
                  child: _getNavigationIcon(
                    ref.watch(mapViewerStateNotiferProvider).navigationStatus,
                  ).icon,
                ),
              );
            },
          ),
        Positioned(
          right: 20,
          top: 20,
          child: CompassButtonWidget(
            mapController: _mapController,
            compassButtonDisplay: compassButtonDisplay,
          ),
        ),
      ],
    );
  }

  IconWithBackground _getNavigationIcon(NavigationStatus navigationStatus) {
    late var iconBg = nearMeWhite;
    switch (navigationStatus) {
      case NavigationStatus.northUp:
        iconBg = nearMeWhite;
        break;
      case NavigationStatus.headUp:
        iconBg = navigationWhite;
        break;
      case NavigationStatus.none:
        iconBg = nearMeBlue;
        break;
    }
    return iconBg;
  }

  Future<bool> _isPermitted() async {
    final geolocatorPlatform = GeolocatorPlatform.instance;
    var parmission = await geolocatorPlatform.checkPermission();
    if (parmission == LocationPermission.denied ||
        parmission == LocationPermission.deniedForever) {
      parmission = await geolocatorPlatform.requestPermission();
    }
    return parmission == LocationPermission.always ||
        parmission == LocationPermission.whileInUse;
  }

  Stream<List<Object>> combineLatest(Iterable<Stream<dynamic>> streams) {
    final first = streams.first.cast<Object>();
    final others = <Stream<Object>>[...streams.skip(1).cast<Stream<Object>>()];
    return first.combineLatestAll(others);
  }
}
