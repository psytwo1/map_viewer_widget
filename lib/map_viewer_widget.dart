library map_viewer_widget;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:map_viewer_widget/map_options_ext.dart';

import 'icon_with_background.dart';
import 'navigation_state.dart';

class MapViewerWidget extends StatefulWidget {
  const MapViewerWidget({
    Key? key,
    required this.children,
    required this.options,
  }) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final List<Widget> children;
  final MapOptions options;
  @override
  State<MapViewerWidget> createState() => _MapViewerWidgetState();
}

class _MapViewerWidgetState extends State<MapViewerWidget> {
  final MapController _mapController = MapController();
  late NavigationState _navigationState;
  late CenterOnLocationUpdate _centerOnLocationUpdate;
  late IconWithBackground _currentNavigationButton = nearMeWhite;
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
  late StreamController<double> _centerCurrentLocationStreamController;
  late MapOptions? _mapOptions;

  @override
  void initState() {
    super.initState();
    _centerOnLocationUpdate = CenterOnLocationUpdate.always;
    _centerCurrentLocationStreamController = StreamController<double>();
    _setNavigationState(NavigationState.northUp, isInit: true);
    FlutterCompass.events!.listen((data) {
      if (_navigationState == NavigationState.headUp) {
        _mapController.rotate(-data.heading!);
      }
    });
    _mapOptions = widget.options.copyWith(
        onPositionChanged: widget.options.onPositionChanged ??
            (MapPosition position, bool hasGesture) {
              if (hasGesture) {
                setState(() {
                  _setNavigationState(NavigationState.none);
                });
              }
            });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Stack(children: [
      FlutterMap(
        mapController: _mapController,
        options: _mapOptions!,
        children: widget.children.followedBy([
          FutureBuilder(
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return LocationMarkerLayerWidget(
                    plugin: LocationMarkerPlugin(
                      centerCurrentLocationStream:
                          _centerCurrentLocationStreamController.stream,
                      centerOnLocationUpdate: _centerOnLocationUpdate,
                    ),
                    options: LocationMarkerLayerOptions(
                      marker: const DefaultLocationMarker(),
                    ));
              } else {
                return Container();
              }
            },
            future: _isPermitted(),
          ),
        ]).toList(),
      ),
      // FutureBuilder(
      //   builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
      //     if (snapshot.hasData && snapshot.data!) {
      // return
      Positioned(
        right: 20,
        bottom: 20,
        child: FloatingActionButton(
          onPressed: () async {
            // Automatically center the location marker on the map when location updated until user interact with the map.
            setState(() {
              if (_navigationState == NavigationState.northUp) {
                _setNavigationState(NavigationState.headUp);
              } else {
                _setNavigationState(NavigationState.northUp);
              }
            });
            // Center the location marker on the map and zoom the map to level 18.
            // _centerCurrentLocationStreamController.add(17);
          },
          backgroundColor: _currentNavigationButton.bgColor,
          child: _currentNavigationButton.icon,
        ),
      )
      // ;
      //     } else {
      //       return Container();
      //     }
      //   },
      //   future: _isPermitted(),
      // )
    ]);
  }

  void _setNavigationState(NavigationState state, {bool isInit = false}) {
    _navigationState = state;
    switch (_navigationState) {
      case NavigationState.northUp:
        _centerOnLocationUpdate = CenterOnLocationUpdate.always;
        _currentNavigationButton = nearMeWhite;
        _centerCurrentLocationStreamController.add(17);
        if (!isInit) {
          _mapController.rotate(0);
        }

        break;
      case NavigationState.headUp:
        _centerOnLocationUpdate = CenterOnLocationUpdate.always;
        _currentNavigationButton = navigationWhite;
        _centerCurrentLocationStreamController.add(17);
        break;
      default:
        _centerOnLocationUpdate = CenterOnLocationUpdate.never;
        _currentNavigationButton = nearMeBlue;
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
}
