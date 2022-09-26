import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_viewer_widget/compass_button_display.dart';
import 'package:map_viewer_widget/map_rotation_stream_controller_manager.dart';

import 'navigation_status.dart';
import 'navigation_status_stream_controller.dart';

/// compass button widget
class CompassButtonWidget extends StatefulWidget {
  final CompassButtonDisplay compassButtonDisplay;
  final MapController mapController;
  final Color backgroundColor;
  final Color foregroundColor;

  /// constructor
  /// [mapController] Specify mapController
  /// [backgroundColor] Specify background color
  /// [foregroundColor] specify foreground color
  const CompassButtonWidget({
    Key? key,
    required this.mapController,
    this.compassButtonDisplay = CompassButtonDisplay.auto,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color.fromARGB(0xff, 0x61, 0x61, 0x61),
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => CompassButtonWidgetState();
}

/// Compass Button Widget State
class CompassButtonWidgetState extends State<CompassButtonWidget> {
  late final CompassButtonDisplay compassButtonDisplay;
  late final MapController mapController;
  late final Color backgroundColor;
  late final Color foregroundColor;

  @override
  void initState() {
    compassButtonDisplay = widget.compassButtonDisplay;
    mapController = widget.mapController;
    backgroundColor = widget.backgroundColor;
    foregroundColor = widget.foregroundColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    NavigationStatus navigationStatus = NavigationStatus.none;

    NavigationStatatusStreamController.stream.listen((event) {
      navigationStatus = event;
    });

    MapRotationStreamControllerManager.addMapController(
        mapController: mapController);
    final mapRotateionStream =
        MapRotationStreamControllerManager.getMapRotationStream(mapController);

    if (compassButtonDisplay != CompassButtonDisplay.none) {
      return StreamBuilder(
        builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
          if (snapshot.hasData) {
            double roteteion = (snapshot.data ?? 0) * pi / 180;
            if (roteteion != 0 ||
                compassButtonDisplay == CompassButtonDisplay.always) {
              return FloatingActionButton(
                onPressed: () {
                  switch (navigationStatus) {
                    case NavigationStatus.headUp:
                      NavigationStatatusStreamController.streamController.sink
                          .add(NavigationStatus.northUp);
                      break;
                    default:
                      mapController.rotate(0);
                      break;
                  }
                },
                backgroundColor: backgroundColor,
                foregroundColor: foregroundColor,
                child: Transform.rotate(
                  angle: roteteion,
                  child: Column(children: [
                    const Text("N"),
                    Icon(
                      Icons.navigation,
                      color: foregroundColor,
                    )
                  ]),
                ),
              );
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        },
        stream: mapRotateionStream,
      );
    } else {
      return Container();
    }
  }

  @override
  void dispose() {
    MapRotationStreamControllerManager.dispose();
    super.dispose();
  }
}
