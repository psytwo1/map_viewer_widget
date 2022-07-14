import 'dart:async';

abstract class MapViewerWidgetStreamFactory<T> {
  MapViewerWidgetStreamFactory() {
    _streamController = createContoller();
  }
  late StreamController<T> _streamController;
  StreamController<T> createContoller();
  StreamController<T> get sc => _streamController;
  Stream<T> get s => _streamController.stream;
}
