library map_viewer_widget;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:map_viewer_widget/center_on_location_update_stream_controller.dart';
import 'package:map_viewer_widget/map_options_ext.dart';
import 'package:map_viewer_widget/navigation_state_stream_controller.dart';
import 'package:map_viewer_widget/turn_on_heading_update_stream_controller.dart';
import 'package:stream_transform/stream_transform.dart';

import 'icon_with_background.dart';
import 'navigation_state.dart';

class MapViewerWidget extends StatelessWidget {
  final List<Widget> children;
  final MapOptions options;
  final bool navigationButtonVisible;
  MapViewerWidget({
    Key? key,
    required this.children,
    required this.options,
    this.navigationButtonVisible = true,
  }) : super(key: key);

  final MapController _mapController = MapController();
  late NavigationState _navigationState;
  // final CenterOnLocationUpdate _centerOnLocationUpdate =
  //     CenterOnLocationUpdate.always;
  // TurnOnHeadingUpdate _turnOnHeadingUpdate = TurnOnHeadingUpdate.never;

  // late IconWithBackground _currentNavigationButton = nearMeWhite;
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

  late MapOptions? _mapOptions;

  final StreamController<NavigationState> _navigationStateStreamController =
      NavigationStateStreamController.streamController;

  // final StreamController<double> _mapRotationStreamController =
  //     StreamController<double>();

  double _oldMapRotation = 0;

  @override
  Widget build(BuildContext context) {
    // Timer.periodic(const Duration(seconds: 1), (timer) {
    //   if (_oldMapRotation != _mapController.rotation) {
    //     _oldMapRotation = _mapController.rotation;
    //     _mapRotationStreamController.sink.add(_oldMapRotation);
    //   }
    // });

    final mapRotateion =
        Stream<double>.periodic(const Duration(seconds: 1), (_) {
      if (_oldMapRotation != _mapController.rotation) {
        _oldMapRotation = _mapController.rotation;
      }
      return _oldMapRotation;
    });

    _navigationStateStreamController.stream.listen(
      (event) {
        _setNavigationState(event, isSetStream: false);
      },
    );

    _setNavigationState(NavigationState.northUp, isInit: true);

    _mapOptions = options.copyWith(
        onPositionChanged: options.onPositionChanged ??
            (MapPosition position, bool hasGesture) {
              if (hasGesture && _navigationState != NavigationState.none) {
                // setState(() {
                _setNavigationState(NavigationState.none);
                // });
              }
            });

    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: _mapOptions!,
        children: children.followedBy([
          FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return StreamBuilder(
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Object>> snapshot) {
                    var centerOnLocationUpdate = CenterOnLocationUpdate.always;
                    var turnOnHeadingUpdate = TurnOnHeadingUpdate.never;
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
                AsyncSnapshot<NavigationState> snapshot) {
              IconWithBackground iconBg = nearMeBlue;
              if (snapshot.hasData) {
                switch (snapshot.data) {
                  case NavigationState.northUp:
                    iconBg = nearMeWhite;
                    break;
                  case NavigationState.headUp:
                    iconBg = navigationWhite;
                    break;
                  case NavigationState.none:
                  default:
                    iconBg = nearMeBlue;
                    break;
                }
              }
              return FloatingActionButton(
                onPressed: navigationButtonAction,
                backgroundColor: iconBg.bgColor,
                child: iconBg.icon,
              );
            },
            stream: _navigationStateStreamController.stream,
          ),
        ),
      StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasData) {
            double roteteion = (snapshot.data ?? 0) * pi / 180;
            if (roteteion != 0) {
              return Positioned(
                right: 20,
                top: 20,
                child: FloatingActionButton(
                  onPressed: () {
                    _mapController.rotate(0);
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: const Color.fromARGB(0xff, 0x61, 0x61, 0x61),
                  child: Transform.rotate(
                    angle: roteteion,
                    child: Column(children: const [
                      Text("N"),
                      Icon(
                        Icons.navigation,
                        color: Color.fromARGB(0xff, 0x61, 0x61, 0x61),
                      )
                    ]),
                  ),
                ),
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        },
        stream: mapRotateion,
      ),
    ]);
  }

  void navigationButtonAction() {
    // setState(() {
    if (_navigationState == NavigationState.northUp) {
      _setNavigationState(NavigationState.headUp);
    } else {
      _setNavigationState(NavigationState.northUp);
    }
    // });
  }

  void _setNavigationState(NavigationState state,
      {bool isInit = false, bool isSetStream = true}) {
    _navigationState = state;
    if (isSetStream) {
      setNavigationStateStream();
    }
    switch (_navigationState) {
      case NavigationState.northUp:
        // _centerOnLocationUpdate = CenterOnLocationUpdate.always;
        CenterOnLocationUpdateStreamController.streamController.sink
            .add(CenterOnLocationUpdate.always);

        // _turnOnHeadingUpdate = TurnOnHeadingUpdate.never;
        TurnOnHeadingUpdateStreamController.streamController.sink
            .add(TurnOnHeadingUpdate.never);
        // _currentNavigationButton = nearMeWhite;
        _centerCurrentLocationStreamController.add(17);
        if (!isInit) {
          _mapController.rotate(0);
        }
        break;

      case NavigationState.headUp:
        // _centerOnLocationUpdate = CenterOnLocationUpdate.always;
        CenterOnLocationUpdateStreamController.streamController.sink
            .add(CenterOnLocationUpdate.always);
        // _turnOnHeadingUpdate = TurnOnHeadingUpdate.always;
        TurnOnHeadingUpdateStreamController.streamController.sink
            .add(TurnOnHeadingUpdate.always);
        // _currentNavigationButton = navigationWhite;
        _centerCurrentLocationStreamController.add(17);
        _turnHeadingUpLocationStreamController.add(null);
        break;

      case NavigationState.none:
      default:
        // _centerOnLocationUpdate = CenterOnLocationUpdate.never;
        CenterOnLocationUpdateStreamController.streamController.sink
            .add(CenterOnLocationUpdate.never);
        TurnOnHeadingUpdateStreamController.streamController.sink
            .add(TurnOnHeadingUpdate.never);
      // _currentNavigationButton = nearMeBlue;
    }
  }

  void setNavigationStateStream() {
    _navigationStateStreamController.add(_navigationState);
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
