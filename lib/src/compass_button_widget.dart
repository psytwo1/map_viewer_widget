import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'compass_button_display.dart';
import 'map_rotation_stream_controller.dart';
import 'map_viewer_widget.dart';
import 'navigation_status.dart';

/// [StreamProvider] of type [double]
final mapRotationStreamProvider = StreamProvider.autoDispose<double>(
  (ref) {
    throw UnimplementedError();
  },
);

/// compass button widget
class CompassButtonWidget extends StatelessWidget {
  /// constructor
  /// [mapController] Specify mapController
  /// [compassButtonDisplay] Specify compassButtonDisplay
  /// [backgroundColor] Specify background color
  /// [foregroundColor] specify foreground color
  const CompassButtonWidget({
    super.key,
    required this.mapController,
    this.compassButtonDisplay = CompassButtonDisplay.auto,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color.fromARGB(0xff, 0x61, 0x61, 0x61),
  });
  final CompassButtonDisplay compassButtonDisplay;
  final MapController mapController;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        mapRotationStreamProvider.overrideWithProvider(
          StreamProvider.autoDispose<double>(
            (ref) {
              final mapRotationStreamController = MapRotationStreamController(
                mapController: mapController,
              );
              ref.onDispose(mapRotationStreamController.dispose);
              return mapRotationStreamController
                  .rotationStreamController.stream;
            },
          ),
        ),
      ],
      child: CompassButtonWidgetBody(
        mapController: mapController,
        compassButtonDisplay: compassButtonDisplay,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}

/// [CompassButtonWidgetBody] is the body of the [CompassButtonWidget].
class CompassButtonWidgetBody extends StatelessWidget {
  const CompassButtonWidgetBody({
    super.key,
    required this.mapController,
    this.compassButtonDisplay = CompassButtonDisplay.auto,
    this.backgroundColor = Colors.white,
    this.foregroundColor = const Color.fromARGB(0xff, 0x61, 0x61, 0x61),
  });
  final CompassButtonDisplay compassButtonDisplay;
  final MapController mapController;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (compassButtonDisplay != CompassButtonDisplay.none) {
      return Consumer(
        builder: (context, ref, child) {
          final navigationStatus =
              ref.watch(mapViewerStateNotiferProvider).navigationStatus;
          final rotation =
              (ref.watch(mapRotationStreamProvider).value ?? 0) * pi / 180;

          if (rotation != 0 ||
              compassButtonDisplay == CompassButtonDisplay.always) {
            return FloatingActionButton(
              onPressed: () {
                if (navigationStatus == NavigationStatus.headUp) {
                  ref
                      .read(mapViewerStateNotiferProvider.notifier)
                      .setNavigationStatus(
                        navigationStatus: NavigationStatus.northUp,
                        mapController: mapController,
                      );
                } else {
                  mapController.rotate(0);
                }
              },
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              child: Transform.rotate(
                angle: rotation,
                child: Column(
                  children: [
                    const Text('N'),
                    Icon(
                      Icons.navigation,
                      color: foregroundColor,
                    )
                  ],
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      );
    } else {
      return Container();
    }
  }
}
