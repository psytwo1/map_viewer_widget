import 'dart:ui';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:positioned_tap_detector_2/positioned_tap_detector_2.dart';

extension MapOptionsExt on MapOptions {
  /// If you give an argument, it will overwrite the value of the member and copy it.
  MapOptions copyWith({
    bool? allowPanningOnScrollingParent,
    Crs? crs,
    LatLng? center,
    LatLngBounds? bounds,
    FitBoundsOptions? boundsOptions,
    double? zoom,
    double? rotation,
    bool? debugMultiFingerGestureWinner,
    bool? enableMultiFingerGestureRace,
    double? rotationThreshold,
    int? rotationWinGestures,
    double? pinchZoomThreshold,
    int? pinchZoomWinGestures,
    double? pinchMoveThreshold,
    int? pinchMoveWinGestures,
    bool? enableScrollWheel,
    double? minZoom,
    double? maxZoom,
    int? interactiveFlags,
    bool? allowPanning,
    void Function(TapPosition, LatLng)? onTap,
    void Function(TapPosition, LatLng)? onLongPress,
    void Function(MapPosition, bool)? onPositionChanged,
    void Function(MapController)? onMapCreated,
    List<MapPlugin>? plugins,
    bool? slideOnBoundaries,
    bool? adaptiveBoundaries,
    Size? screenSize,
    MapController? controller,
    LatLng? swPanBoundary,
    LatLng? nePanBoundary,
    LatLngBounds? maxBounds,
  }) {
    return MapOptions(
      allowPanningOnScrollingParent:
          allowPanningOnScrollingParent ?? this.allowPanningOnScrollingParent,
      crs: crs ?? this.crs,
      center: center ?? this.center,
      bounds: bounds ?? this.bounds,
      boundsOptions: boundsOptions ?? this.boundsOptions,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
      debugMultiFingerGestureWinner:
          debugMultiFingerGestureWinner ?? this.debugMultiFingerGestureWinner,
      enableMultiFingerGestureRace:
          enableMultiFingerGestureRace ?? this.enableMultiFingerGestureRace,
      rotationThreshold: rotationThreshold ?? this.rotationThreshold,
      rotationWinGestures: rotationWinGestures ?? this.rotationWinGestures,
      pinchZoomThreshold: pinchZoomThreshold ?? this.pinchZoomThreshold,
      pinchZoomWinGestures: pinchZoomWinGestures ?? this.pinchZoomWinGestures,
      pinchMoveThreshold: pinchMoveThreshold ?? this.pinchMoveThreshold,
      pinchMoveWinGestures: pinchMoveWinGestures ?? this.pinchMoveWinGestures,
      enableScrollWheel: enableScrollWheel ?? this.enableScrollWheel,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      interactiveFlags: interactiveFlags ?? this.interactiveFlags,
      allowPanning: allowPanning ?? this.allowPanning,
      onTap: onTap ?? this.onTap,
      onLongPress: onLongPress ?? this.onLongPress,
      onPositionChanged: onPositionChanged ?? this.onPositionChanged,
      onMapCreated: onMapCreated ?? this.onMapCreated,
      plugins: plugins ?? this.plugins,
      slideOnBoundaries: slideOnBoundaries ?? this.slideOnBoundaries,
      adaptiveBoundaries: adaptiveBoundaries ?? this.adaptiveBoundaries,
      screenSize: screenSize ?? this.screenSize,
      controller: controller ?? this.controller,
      swPanBoundary: swPanBoundary ?? this.swPanBoundary,
      nePanBoundary: nePanBoundary ?? this.nePanBoundary,
      maxBounds: maxBounds ?? this.maxBounds,
    );
  }
}
