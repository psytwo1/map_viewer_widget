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
import 'map_viewer_state.dart';
import 'map_viewer_state_notifer.dart';
import 'navigation_status.dart';

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
    this.defaultCenterOnLocationUpdate = FollowOnLocationUpdate.always,
    this.defaultTurnOnHeadingUpdate = TurnOnHeadingUpdate.never,
    this.defaultNavigationStatus = NavigationStatus.northUp,
    this.mapController,
    this.nonRotatedChildren = const [],
    this.navigationZoom = 17,
  });

  /// A set of layers' widgets to used to create the layers on the map.
  final List<Widget> children;

  /// These layers won't be rotated.
  ///
  /// These layers will render above layers
  final List<Widget> nonRotatedChildren;

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
  final FollowOnLocationUpdate defaultCenterOnLocationUpdate;

  /// Default Turn On Heading Update
  final TurnOnHeadingUpdate defaultTurnOnHeadingUpdate;

  /// Default Navigation Status
  /// See [NavigationStatus] for details
  final NavigationStatus defaultNavigationStatus;

  /// Specified when using [MapController] from outside the class
  final MapController? mapController;

  /// Specify navigation zoom
  final double navigationZoom;

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
    this.nonRotatedChildren = const [],
    this.navigationZoom = 17,
  });

  /// A set of layers' widgets to used to create the layers on the map.
  final List<Widget> children;

  /// These layers won't be rotated.
  ///
  /// These layers will render above layers
  final List<Widget> nonRotatedChildren;

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

  /// Specify navigation zoom
  final double navigationZoom;

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
                              zoom: navigationZoom,
                            );
                      }
                    },
              ),
              nonRotatedChildren: nonRotatedChildren,
              children: children.followedBy([
                FutureBuilder(
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return Consumer(
                        builder: (context, ref, child) {
                          return CurrentLocationLayer(
                            followCurrentLocationStream: ref
                                .watch(
                                  mapViewerStateNotiferProvider.notifier,
                                )
                                .centerCurrentLocationStreamController
                                .stream,
                            followOnLocationUpdate: ref
                                .watch(mapViewerStateNotiferProvider)
                                .centerOnLocationUpdate,
                            turnOnHeadingUpdate: ref
                                .watch(mapViewerStateNotiferProvider)
                                .turnOnHeadingUpdate,
                            turnHeadingUpLocationStream: ref
                                .watch(mapViewerStateNotiferProvider.notifier)
                                .turnHeadingUpLocationStreamController
                                .stream,
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
                            zoom: navigationZoom,
                          );
                    } else {
                      ref
                          .read(mapViewerStateNotiferProvider.notifier)
                          .setNavigationStatus(
                            navigationStatus: NavigationStatus.northUp,
                            mapController: _mapController,
                            zoom: navigationZoom,
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
