import 'dart:async';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/functions/is.dart';

import 'global.dart';

class Purge {
  String root;
  Stopwatch _consume = Stopwatch();
  Duration _duration = Duration(seconds: 1);
  Timer _timer;

  Purge({Duration duration, bool autostart = false}) {
    try {
      _duration = duration ?? _duration;
    }
    catch (exc) {
      print('constructor: $exc');
    }
    finally {
      if (autostart) start();
    }
  }

  bool get isActive => _timer != null && _timer.isActive;
  bool get isRunning => _consume.isRunning;

  bool start() {
    bool succeed = false;
    try {
      if (isRunning)
        return succeed;
      if (root == null || !Directory(root).existsSync())
        return succeed;
      if (!isActive) {
        _timer = Timer.periodic(_duration, _periodic);
        succeed = true;
      }
    }
    catch (exc) {
      print('start: $exc');
    }
    return succeed;
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
      print('stop: $exc');
    }
    return succeed;
  }

  void _periodic(Timer timer) async {
    if (_consume.isRunning)
      return;
    try {
      _consume.start();
      await _purge(root);
      _consume.stop();
    }
    catch (exc) {
      print('periodic: $exc');
    }
    finally {
      _consume.reset();
    }
  }

  Future<int> _purge(String root) async {
    int purged = 0;
    try {
      print('find: <<<<< began >>>>>');
      final String pattern = '*';
      find(pattern, 
        root: root, 
        recursive: true, 
        types: [Find.directory], 
        progress: Progress((String found) {
          bool succeed = false;
          try {
            if (!_timer.isActive)
              return succeed;
            List<String> files = find(pattern, root: found, recursive: false).toList();
            print('find: path=$found, files=${files.length}');
            files.forEach((String file) { 
              final DateTime datetime = lastModified(file);
              print('find: file=$file, datetime=$datetime');
            });
            succeed = true;
          }
          catch (exc) {
            print('path: $exc');
          }
          return succeed;
      }
      ));
      print('find: <<<<< ended >>>>>');
    }
    catch (exc) {
      print('purge: $exc');
    }
    finally {
      final int consumed = _consume.elapsedMilliseconds;
      print('purge: ended -> purged=$purged, consumed=$consumed');
    }
    return purged;
  }
}
