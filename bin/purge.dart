/// dcache designed by ilshookim
/// MIT License
/// 
/// https://github.com/ilshookim/dcache
/// 
import 'dart:async';
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:dcli/src/functions/is.dart';
import 'package:stack_trace/stack_trace.dart';

import 'global.dart';

class Purge {
  String root = Global.defaultRoot;
  int count = int.tryParse(Global.defaultCount);
  String printAll = Global.defaultPrintAll;

  Stopwatch _consume = Stopwatch();
  Duration _duration = Duration(seconds: 1);
  Timer _timer;

  Purge({Duration duration, bool autostart = false}) {
    final String function = Trace.current().frames[0].member;
    try {
      _duration = duration ?? _duration;
    }
    catch (exc) {
      print('$function: $exc');
    }
    finally {
      if (autostart) start();
    }
  }

  bool get isActive => _timer != null && _timer.isActive;
  bool get isRunning => _consume.isRunning;

  bool start() {
    final String function = Trace.current().frames[0].member;
    bool succeed = false;
    try {
      if (isRunning)
        return succeed;
      final bool rootExists = Directory(root).existsSync();
      if (root == null || !rootExists)
        return succeed;
      if (!isActive) {
        _timer = Timer.periodic(_duration, _periodic);
        succeed = true;
      }
    }
    catch (exc) {
      print('$function: $exc');
    }
    return succeed;
  }

  bool stop() {
    final String function = Trace.current().frames[0].member;
    bool succeed = false;
    try {
      if (isActive) {
        _timer.cancel();
        succeed = true;
      }
    }
    catch (exc) {
      print('$function: $exc');
    }
    return succeed;
  }

  void _periodic(Timer timer) {
    if (isRunning)
      return;
    final String function = Trace.current().frames[0].member;
    int purged = 0;
    try {
      _consume.start();
      purged = _purge(root);
      _consume.stop();
    }
    catch (exc) {
      print('$function: $exc');
    }
    finally {
      final bool printAllFiles = printAll.parseBool();
      if (printAllFiles) {
        final int consumed = _consume.elapsedMilliseconds;
        print('purge: purged=$purged, consumed=$consumed <- root=$root, count=$count, printAll=$printAll');
      }
      _consume.reset();
    }
  }

  int _purge(String root) {
    final String function = Trace.current().frames[0].member;
    int purged = 0;
    try {
      final String pattern = '*';
      final bool printAllFiles = printAll.parseBool();
      find(pattern, 
        root: root, 
        recursive: true, 
        types: [Find.directory], 
        progress: Progress((String found) {
          bool succeed = false;
          try {
            if (!isActive)
              return succeed;
            final List<String> files = find(pattern, root: found, recursive: false).toList();
            final bool purgeReally = true;
            final bool purgeHere = files.length > count;
            if (printAllFiles) {
              print('> path=$found: files=${files.length}');
              for (int i=0; i<files.length; i++) {
                final String file = files[i];
                print('file[$i]=$file');
              }
            }
            if (purgeHere) {
              print('> too many files in a path: path=$found, files=${files.length}, count=$count');
              files.sort((a, b) {
                final DateTime l = lastModified(a);
                final DateTime r = lastModified(b);
                return r.compareTo(l);
              });
              for (int i=count; i<files.length; i++) {
                final String file = files[i];
                final DateTime datetime = lastModified(file);
                print('>>> deleted: index=$i, file=$file, datetime=$datetime');
                if (purgeReally) delete(file);
              }
            }
            succeed = true;
          }
          catch (exc) {
            print('$function: $exc');
          }
          return succeed;
      }));
    }
    catch (exc) {
      print('$function: $exc');
    }
    return purged;
  }
}
