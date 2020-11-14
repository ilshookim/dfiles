import 'dart:async';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/functions/is.dart';

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

  Future<int> _purge(String root) async {
    bool exists = root.isNotEmpty && Directory(root).existsSync();
    if (!exists) return 0;
    int purged = 0;
    try {
      print('find: ===============');
      final String root2 = join(root, '..', '..');
      final String pattern = '*';
      find(pattern, 
        root: root2, 
        recursive: true, 
        types: [Find.directory], 
        progress: Progress((String path) {
          try {
            if (!_timer.isActive)
              return false;
            List<String> files = find(pattern, root: path, recursive: false).toList();
            print('find: path=$path, files=${files.length}');
            // final DateTime datetime = lastModified(path);
            // print('find: path=$path, datetime=$datetime');
            return true;
          }
          catch (exc) {
            print('path: exc=$exc');
          }
      }));
      print('find: <<<<<end>>>>>');
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
}
