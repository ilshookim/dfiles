import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'global.dart';

class Purge {
  Stopwatch _consume = Stopwatch();
  Duration _duration = Duration(seconds: 1);
  String _path = Global.currentPath;
  Timer _timer;

  Purge({String path, Duration duration, bool autostart = true}) {
    try {
      _path = path ?? _path;
      _duration = duration ?? _duration;
    }
    catch (exc) {
      print('constructor: exc=$exc');
    }
    finally {
      if (autostart) start();
    }
  }

  bool get isActive {
    return (_timer != null && _timer.isActive);
  }

  bool get isRunning {
    return _consume.isRunning;
  }

  bool stop() {
    bool succeed = false;
    try {
      if (isActive) {
        _timer.cancel();
        succeed = true;
      }
    }
    catch (exc) {
      print('stop: exc=$exc');
    }
    return succeed;
  }

  bool start() {
    bool succeed = false;
    try {
      if (!isActive) {
        _timer = Timer.periodic(_duration, _periodic);
        succeed = true;
      }
    }
    catch (exc) {
      print('start: exc=$exc');
    }
    return succeed;
  }

  void _periodic(Timer timer) async {
    if (_consume.isRunning)
      return;
    try {
      _consume.start();
      await _purge(_path);
      _consume.stop();
    }
    catch (exc) {
      print('periodic: exc=$exc');
    }
    finally {
      _consume.reset();
    }
  }

  Future<int> _purge(String path) async {
    bool exists = path.isNotEmpty && Directory(path).existsSync();
    if (!exists) return 0;
    int purged = 0;
    try {
      final int seconds = _random(min: 1, max: 20);
      print('purge: began -> seconds=$seconds, path=$path, exists=$exists');
      await Future.delayed(Duration(seconds: seconds));
      purged = seconds;
    }
    catch (exc) {
      print('purge: exc=$exc');
    }
    finally {
      final int consumed = _consume.elapsedMilliseconds;
      print('purge: ended -> purged=$purged, consumed=$consumed');
    }
    return purged;
  }

  int _random({int min = 1, int max = 30}) {
    return min + Random().nextInt(max - min);
  }
}
