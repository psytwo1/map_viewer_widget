library map_viewer_widget;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:map_viewer_widget/center_on_location_update_stream_controller.dart';
import 'package:map_viewer_widget/compass_button_display.dart';
import 'package:map_viewer_widget/map_options_ext.dart';
import 'package:map_viewer_widget/navigation_status_stream_controller.dart';
import 'package:map_viewer_widget/turn_on_heading_update_stream_controller.dart';
import 'package:stream_transform/stream_transform.dart';

import 'compass_button_widget.dart';
import 'icon_with_background.dart';
import 'navigation_status.dart';

/// MapViewerWidget is map viewer widget
class MapViewerWidget extends StatelessWidget {
  /// A set of layers' widgets to used to create the layers on the map.
  final List<Widget> children;

  /// [MapOptions] to create a [MapState] with.
  ///
  /// This property must not be null.
  final MapOptions options;

  /// Visibility of navigation buttons
  final bool navigationButtonVisible;

  /// Compass button display mode
  /// Default value is [auto]
  /// See [CompassButtonDisplay] for details
  final CompassButtonDisplay compassButtonDisplay;

  /// Default Center On Location Update
  final CenterOnLocationUpdate defaultCenterOnLocationUpdate;

  /// Default Turn On Heading Update
  final TurnOnHeadingUpdate defaultTurnOnHeadingUpdate;

  /// Default Navigation Status
  /// See [NavigationStatus] for details
  final NavigationStatus defaultNavigationStatus;

  /// A constructor of `MapViewerWidget` class.
  MapViewerWidget({
    Key? key,
    required this.children,
    required this.options,
    this.navigationButtonVisible = true,
    this.compassButtonDisplay = CompassButtonDisplay.auto,
    this.defaultCenterOnLocationUpdate = CenterOnLocationUpdate.always,
    this.defaultTurnOnHeadingUpdate = TurnOnHeadingUpdate.never,
    this.defaultNavigationStatus = NavigationStatus.northUp,
  }) : super(key: key);

  final MapController _mapController = MapController();
  final IconWithBackground nearMeWhite = const IconWithBackground(
      bgColor: Colors.blue,
      icon: Icon(
        Icons.near_me,
        color: Colors.white,
      ));
  final IconWithBackground nearMeBlue = const IconWithBackground(
      bgColor: Colors.white,
      icon: Icon(
        Icons.near_me,
        color: Colors.blue,
      ));
  final IconWithBackground navigationWhite = const IconWithBackground(
      bgColor: Colors.blue, icon: Icon(Icons.navigation, color: Colors.white));
  final StreamController<double> _centerCurrentLocationStreamController =
      StreamController<double>();
  final StreamController<void> _turnHeadingUpLocationStreamController =
      StreamController<void>();

  @override
  Widget build(BuildContext context) {
    NavigationStatus navigationStatus = defaultNavigationStatus;

    NavigationStatatusStreamController.stream.listen(
      (event) {
        navigationStatus = event;
        _setNavigationStatus(event);
      },
    );

    TurnOnHeadingUpdateStreamController.stream.listen((event) {
      if (event == TurnOnHeadingUpdate.never &&
          navigationStatus != NavigationStatus.headUp) {
        // _mapController.rotate(0);
      }
    });

    // MapRotationObserver(mapController: _mapController)
    //     .mapRotateionStream!
    //     .listen((event) {
    //   if (navigationStatus != NavigationStatus.headUp) {
    //     _mapController.rotate(0);
    //   }
    // });

    MapOptions mapOptions = options.copyWith(
        onPositionChanged: options.onPositionChanged ??
            (MapPosition position, bool hasGesture) {
              if (hasGesture && navigationStatus != NavigationStatus.none) {
                NavigationStatatusStreamController.streamController.sink
                    .add(NavigationStatus.none);
              }
            });
    // _setNavigationStatus(navigationStatus, isInit: true);
    NavigationStatatusStreamController.streamController.sink
        .add(navigationStatus);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: mapOptions,
          children: children.followedBy([
            FutureBuilder(
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData && snapshot.data!) {
                  return StreamBuilder(
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Object>> snapshot) {
                      var centerOnLocationUpdate =
                          defaultCenterOnLocationUpdate;
                      var turnOnHeadingUpdate = defaultTurnOnHeadingUpdate;
                      if (snapshot.hasData) {
                        centerOnLocationUpdate =
                            snapshot.data![0] as CenterOnLocationUpdate;
                        turnOnHeadingUpdate =
                            snapshot.data![1] as TurnOnHeadingUpdate;
                      }
                      return LocationMarkerLayerWidget(
                        plugin: LocationMarkerPlugin(
                          centerCurrentLocationStream:
                              _centerCurrentLocationStreamController.stream,
                          centerOnLocationUpdate: centerOnLocationUpdate,
                          turnOnHeadingUpdate: turnOnHeadingUpdate,
                          turnHeadingUpLocationStream:
                              _turnHeadingUpLocationStreamController.stream,
                        ),
                        options: LocationMarkerLayerOptions(
                          marker: const DefaultLocationMarker(),
                        ),
                      );
                    },
                    stream: combineLatest([
                      CenterOnLocationUpdateStreamController.stream,
                      TurnOnHeadingUpdateStreamController.stream
                    ]),
                  );
                } else {
                  return Container();
                }
              },
              future: _isPermitted(),
            ),
          ]).toList(),
        ),
        if (navigationButtonVisible)
          Positioned(
            right: 20,
            bottom: 20,
            child: StreamBuilder(
              builder: (BuildContext context,
                  AsyncSnapshot<NavigationStatus> snapshot) {
                IconWithBackground iconBg = nearMeBlue;
                // navigationStatus = defaultNavigationStatus;
                if (snapshot.hasData) {
                  navigationStatus = snapshot.data ?? defaultNavigationStatus;
                }
                switch (navigationStatus) {
                  case NavigationStatus.northUp:
                    iconBg = nearMeWhite;
                    break;
                  case NavigationStatus.headUp:
                    iconBg = navigationWhite;
                    break;
                  case NavigationStatus.none:
                  default:
                    iconBg = nearMeBlue;
                    break;
                }

                return FloatingActionButton(
                  onPressed: () {
                    navigationButtonAction(navigationStatus);
                  },
                  backgroundColor: iconBg.bgColor,
                  child: iconBg.icon,
                );
              },
              stream: NavigationStatatusStreamController.stream,
            ),
          ),
        Positioned(
          right: 20,
          top: 20,
          child: CompassButtonWidget(
            mapController: _mapController,
          ),
        ),
      ],
    );
  }

  void navigationButtonAction(NavigationStatus navigationStatus) {
    if (navigationStatus == NavigationStatus.northUp) {
      NavigationStatatusStreamController.streamController.sink
          .add(NavigationStatus.headUp);
    } else {
      NavigationStatatusStreamController.streamController.sink
          .add(NavigationStatus.northUp);
    }
  }

  void _setNavigationStatus(NavigationStatus status, {bool isInit = false}) {
    switch (status) {
      case NavigationStatus.northUp:
        CenterOnLocationUpdateStreamController.streamController.sink
            .add(CenterOnLocationUpdate.always);
        TurnOnHeadingUpdateStreamController.streamController.sink
            .add(TurnOnHeadingUpdate.never);
        _centerCurrentLocationStreamController.add(17);
        if (!isInit) {
          _mapController.rotate(0);
        }
        break;

      case NavigationStatus.headUp:
        CenterOnLocationUpdateStreamController.streamController.sink
            .add(CenterOnLocationUpdate.always);
        TurnOnHeadingUpdateStreamController.streamController.sink
            .add(TurnOnHeadingUpdate.always);
        _centerCurrentLocationStreamController.add(17);
        _turnHeadingUpLocationStreamController.add(null);
        break;

      case NavigationStatus.none:
      default:
        CenterOnLocationUpdateStreamController.streamController.sink
            .add(CenterOnLocationUpdate.never);
        TurnOnHeadingUpdateStreamController.streamController.sink
            .add(TurnOnHeadingUpdate.never);
    }
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

  Stream<List<Object>> combineLatest(Iterable<Stream> streams) {
    final Stream<Object> first = streams.first.cast<Object>();
    final List<Stream<Object>> others = [
      ...streams.skip(1).cast<Stream<Object>>()
    ];
    return first.combineLatestAll(others);
  }
}
