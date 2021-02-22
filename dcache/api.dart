/// dcache designed by ilshookim
/// MIT License
/// 
/// https://github.com/ilshookim/dcache
/// 
import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:stack_trace/stack_trace.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'global.dart';
import 'purge.dart';

class API {
  final Purge purge = Purge();
  final Router router = Router();

  Future<Response> onStop(Request request) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final bool succeed = purge.stop();
      final bool running = purge.isRunning;
      message = 'purge: stop=$succeed, running=$running';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Future<Response> onStart(Request request) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final bool succeed = purge.start();
      final bool running = purge.isRunning;
      message = 'purge: start=$succeed, running=$running, timer=${purge.timer}, monitor=${purge.monitor}';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Future<Response> onDays(Request request, String days) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final int older = purge.days;
      final int newly = int.tryParse(days) ?? purge.days;
      purge.days = newly;
      message = 'days: old=$older -> new=$newly';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Future<Response> onCount(Request request, String count) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final int older = purge.count;
      final int newly = int.tryParse(count) ?? purge.count;
      purge.count = newly;
      message = 'count: old=$older -> new=$newly';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Future<Response> onTimer(Request request, String timer) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final int older = purge.timer;
      final int newly = int.tryParse(timer) ?? purge.timer;
      purge.timer = newly;

      final bool stopped = purge.stop();
      final bool started = purge.start();
      final bool running = purge.isRunning;
      message = 'timer: old=$older -> new=$newly, started=$started, stopped=$stopped, running=$running, monitor=${purge.monitor}';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Future<Response> onPrintAll(Request request, String printAll) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final String older = purge.printAll;
      final String newly = printAll ?? purge.printAll;
      purge.printAll = newly;
      message = 'printAll: old=$older -> new=$newly';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Handler v1({String monitor, int count, int days, int timer, String monitorRecursive, String printAll}) {
    final String function = Trace.current().frames[0].member;
    try {
      router.get(uri('stop'), onStop);
      router.get(uri('start'), onStart);
      router.get(uri('days/<days>'), onDays);
      router.get(uri('count/<count>'), onCount);
      router.get(uri('timer/<timer>'), onTimer);
      router.get(uri('printAll/<printAll>'), onPrintAll);

      final String ver1 = "v1";
      router.get(uri('stop', version: ver1), onStop);
      router.get(uri('start', version: ver1), onStart);
      router.get(uri('days/<days>', version: ver1), onDays);
      router.get(uri('count/<count>', version: ver1), onCount);
      router.get(uri('timer/<timer>', version: ver1), onTimer);
      router.get(uri('printAll/<printAll>', version: ver1), onPrintAll);

      final Handler index = createStaticHandler(Global.currentPath, defaultDocument: Global.indexName);
      final Handler favicon = createStaticHandler(Global.currentPath, defaultDocument: Global.faviconName);
      final Handler cascade = Cascade().add(index).add(favicon).add(router.handler).handler;
      final Handler handler = Pipeline().addMiddleware(logRequests()).addHandler(cascade);
      return handler;
    }
    catch (exc) {
      print('$function: $exc');
    }
    finally {
      purge.monitor = monitor ?? purge.monitor;
      purge.count = count ?? purge.count;
      purge.days = days ?? purge.days;
      purge.timer = timer ?? purge.timer;
      purge.monitorRecursive = monitorRecursive ?? purge.monitorRecursive;
      purge.printAll = printAll ?? purge.printAll;
      purge.start();
    }
    final Handler defaultHandler = Pipeline().addHandler((Request request) {
      return Response.ok('Request for ${request.url}');
    });
    return defaultHandler;
  }

  String uri(String path, {String version}) {
    if (version == null)
      return join('/', path);
    return join('/', version, path);
  }
}
