import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:map_viewer_widget/compass_button_display.dart';

import 'navigation_status.dart';
import 'navigation_status_stream_controller.dart';

class CompassButtonWidget extends StatelessWidget {
  final CompassButtonDisplay compassButtonDisplay;
  final MapController mapController;
  final Color backgroundColor;
  final Color foregroundColor;

  const CompassButtonWidget({
    Key? key,
    required this.mapController,
    this.compassButtonDisplay = CompassButtonDisplay.auto,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color.fromARGB(0xff, 0x61, 0x61, 0x61),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NavigationStatus navigationStatus = NavigationStatus.none;
    double oldMapRotation = 0;

    NavigationStatatusStreamController.stream.listen((event) {
      navigationStatus = event;
    });

    final mapRotateion =
        Stream<double>.periodic(const Duration(seconds: 1), (_) {
      if (oldMapRotation != mapController.rotation) {
        if (navigationStatus == NavigationStatus.northUp) {
          oldMapRotation = 0;
          mapController.rotate(0);
        } else {
          oldMapRotation = mapController.rotation;
        }
      }
      return oldMapRotation;
    });

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
                      break;
                  }
                  mapController.rotate(0);
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
        stream: mapRotateion,
      );
    } else {
      return Container();
    }
  }
}
