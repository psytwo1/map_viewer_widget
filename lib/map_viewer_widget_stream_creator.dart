import 'dart:async';

/// Stream controller creation class
abstract class MapViewerWidgetStreamCreator<T> {
  MapViewerWidgetStreamCreator() {
    _streamController = createContoller();
  }
  late StreamController<T> _streamController;
  StreamController<T> createContoller();
  StreamController<T> get sc => _streamController;
  Stream<T> get s => _streamController.stream;
}
