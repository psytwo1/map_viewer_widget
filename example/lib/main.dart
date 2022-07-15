import 'dart:async';

import 'package:example/osm_bright_ja_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_viewer_widget/map_viewer_widget.dart';
import 'package:map_viewer_widget/navigation_state.dart';
import 'package:map_viewer_widget/navigation_state_stream_controller.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapViewer Example',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'MapViewer Example'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    final StreamController<NavigationState> sc =
        NavigationStateStreamController.streamController;
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(title),
      ),
      body: SafeArea(
          child: Stack(children: [
        MapViewerWidget(
            options: MapOptions(
              center: LatLng(39.640278, 141.946572),
              zoom: 8,
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
            ]), // This trailing comma makes auto-formatting nicer for build methods.
        Positioned(
            right: 20,
            bottom: 120,
            child: FloatingActionButton(
              child: StreamBuilder(
                builder: (BuildContext context,
                    AsyncSnapshot<NavigationState> snapShot) {
                  String text = "not ready";
                  if (snapShot.hasData) {
                    switch (snapShot.data) {
                      case NavigationState.headUp:
                        text = "headUp";
                        break;
                      case NavigationState.northUp:
                        text = "northUp";
                        break;
                      case NavigationState.none:
                        text = "none";
                        break;
                      default:
                        text = "not ready";
                    }
                  }
                  return Text(text);
                },
                stream: NavigationStateStreamController.stream,
              ),
              onPressed: () {
                sc.sink.add(NavigationState.northUp);
              },
            ))
      ])),
    );
  }

  _mapTheme(BuildContext context) {
    // maps are rendered using themes
    // to provide a dark theme do something like this:
    // if (MediaQuery.of(context).platformBrightness == Brightness.dark) return myDarkTheme();
    // return ProvidedThemes.lightTheme();
    return ThemeReader().read(osmBrightJaStyle());
  }

  VectorTileProvider _cachingTileProvider(String urlTemplate) {
    return MemoryCacheVectorTileProvider(
        delegate: NetworkVectorTileProvider(
            urlTemplate: urlTemplate,
            // this is the maximum zoom of the provider, not the
            // maximum of the map. vector tiles are rendered
            // to larger sizes to support higher zoom levels
            maximumZoom: 14),
        maxSizeBytes: 1024 * 1024 * 2);
  }

  String _urlTemplate() {
    // Stadia Maps source https://docs.stadiamaps.com/vector/
    // return 'https://tiles.stadiamaps.com/data/openmaptiles/{z}/{x}/{y}.pbf?api_key=$apiKey';

    return 'https://tile2.openstreetmap.jp/data/planet/{z}/{x}/{y}.pbf';

    // Mapbox source https://docs.mapbox.com/api/maps/vector-tiles/#example-request-retrieve-vector-tiles
    // return 'https://api.mapbox.com/v4/mapbox.mapbox-streets-v8/{z}/{x}/{y}.mvt?access_token=$apiKey',
  }
}
