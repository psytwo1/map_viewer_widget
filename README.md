<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

# MapViewerWidget

MapViewerWidget is a FlutterMap display widget. It will be the base of the map application.

![Screenshot](https://user-images.githubusercontent.com/17922561/187884582-6dddaf3b-3c7d-4cc5-9174-6b3bd232a4da.png)

## Features

MapViewerWidget has the following features
* Map display
* Map rotation
* Current location display using GPS
* Map rotation using compass
  * North up
  * Heads up
  
## Getting started

Add the package with the following command
```bash
flutter pub add map_viewer_widget
```

## Usage

refer to the following. See `/example` folder for details

```dart
MapViewerWidget(
            options: MapOptions(
              center: LatLng(39.640278, 141.946572),
              zoom: 14,
              maxZoom: 14,
              plugins: [VectorMapTilesPlugin()],
            ),
            children: [
              VectorTileLayerWidget(
                  options: VectorTileLayerOptions(
                      theme: _mapTheme(context),
                      tileProviders: TileProviders({
                        'openmaptiles': _cachingTileProvider(_urlTemplate())
                      })))
            ] // Specify the visible layer as children
            ),
        Positioned(
            right: 20,
            bottom: 120,
            child: FloatingActionButton(
              child: StreamBuilder(
                builder: (BuildContext context,
                    AsyncSnapshot<NavigationStatus> snapShot) {
                  String text = "none";
                  NavigationStatus navigationStatus = NavigationStatus.northUp;
                  if (snapShot.hasData) {
                    navigationStatus =
                        snapShot.data ?? NavigationStatus.northUp;
                  }
                  switch (navigationStatus) {
                    case NavigationStatus.headUp:
                      text = "headUp";
                      break;
                    case NavigationStatus.northUp:
                      text = "northUp";
                      break;
                    case NavigationStatus.none:
                    default:
                      text = "none";
                      break;
                  }

                  return Text(
                    text,
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  );
                },
                stream: NavigationStatatusStreamController.stream,
              ),
              onPressed: () {
                sc.sink.add(NavigationStatus.northUp);
              },
            ))```
