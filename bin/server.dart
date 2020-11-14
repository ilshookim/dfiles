import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:path/path.dart';
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

import 'global.dart';

class Purge {
  Stopwatch _consume = Stopwatch();
  Duration _duration = Duration(seconds: 1);
  String _path = Global.currentPath;
  Timer _timer;

  Purge({String path, Duration duration, bool autostart = true}) {
    _path = path ?? _path;
    _duration = duration ?? _duration;
    if (autostart) start();
  }

  bool stop() {
    bool succeed = false;
    try {
      bool already = _timer != null && _timer.isActive;
      if (already) _timer.cancel();
      succeed = _timer.isActive;
    }
    catch (exc) {
      print('stop: exc=$exc');
    }
    return succeed;
  }

  bool start() {
    bool succeed = false;
    try {
      bool already = _timer != null && _timer.isActive;
      if (!already)
        _timer = Timer.periodic(_duration, _periodic);
      succeed = _timer != null && _timer.isActive;
    }
    catch (exc) {
      print('start: exc=$exc');
    }
    return succeed;
  }

  void _periodic(Timer timer) async {
    if (_consume.isRunning)
      return;
    print('purge: began');
    int purged = 0;
    int consumed = 0;
    try {
      _consume.start();
      purged = await _purge(_path);
      _consume.stop();
      consumed = _consume.elapsedMilliseconds;
    }
    catch (exc) {
      print('purge: exc=$exc');
    }
    finally {
      _consume.reset();
    }
    print('purge: ended -> purged=$purged, consumed=$consumed');
  }

  Future<int> _purge(String path) async {
    bool exists = path.isNotEmpty && Directory(path).existsSync();
    if (!exists) return 0;
    int purged = 0;
    try {
      final int seconds = _random(min: 1, max: 20);
      print('purge: seconds=$seconds, path=$path, exists=$exists');
      await Future.delayed(Duration(seconds: seconds));
    }
    catch (exc) {
      print('purge: exc=$exc');
    }
    return purged;
  }

  int _random({int min = 1, int max = 30}) {
    return min + Random().nextInt(max - min);
  }
}

void main(List<String> arguments) async {
  try {
    final Purge purge = Purge(autostart: true);
    final Router api = Router();

    api.get('/purge/start', (Request request) async {
      purge.start();
      return Response.ok('Purge Started');
    });

    api.get('/purge/stop', (Request request) async {
      purge.stop();
      return Response.ok('Purge Stopped');
    });

    final String path = join(Global.currentPath, '.');
    final Handler index = createStaticHandler(path, defaultDocument: Global.indexName);
    final Handler favicon = createStaticHandler(path, defaultDocument: Global.faviconName);
    final Handler cascade = Cascade().add(index).add(favicon).add(api.handler).handler;

    final ArgParser argParser = ArgParser()..addOption(Global.portOption, abbr: Global.portAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPort;

    final String host = Global.defaultHost;
    final int port = int.tryParse(portOption);
    final Handler handler = const Pipeline().addMiddleware(logRequests()).addHandler(cascade);
    final HttpServer server = await serve(handler, host, port);

    final Map pubspec = await Global.pubspec();
    final String appName = pubspec[Global.name];
    final String appDesc = pubspec[Global.description];
    final String appVer = pubspec[Global.version];
    print('$appName $appVer - $appDesc serving at http://${server.address.host}:${server.port}');
  }
  catch (exc) {
    print('dcache: exc=$exc');
  }
}
