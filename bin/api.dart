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
      message = 'purge: start=$succeed, running=$running, period=${purge.period}, root=${purge.root}';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Future<Response> onRestart(Request request) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final bool stopped = purge.stop();
      final bool started = purge.start();
      final bool running = purge.isRunning;
      message = 'purge: started=$started, stopped=$stopped, running=$running, period=${purge.period}, root=${purge.root}';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Future<Response> onPeriod(Request request, String period) async {
    final String function = Trace.current().frames[0].member;
    String message = 'empty';
    try {
      final int older = purge.period;
      final int newly = int.tryParse(period) ?? purge.period;
      purge.period = newly;
      message = 'period: old=$older -> new=$newly';
    }
    catch (exc) {
      message = '$function: $exc';
    }
    finally {
      print(message);
    }
    return Response.ok(message);
  }

  Handler v1({String root, int count, int period, String printAll}) {
    final String function = Trace.current().frames[0].member;
    try {
      router.get(uri('stop'), onStop);
      router.get(uri('start'), onStart);
      router.get(uri('restart'), onRestart);
      router.get(uri('period/<period>'), onPeriod);

      final String ver1 = "v1";
      router.get(uri('stop', version: ver1), onStop);
      router.get(uri('start', version: ver1), onStart);
      router.get(uri('restart', version: ver1), onRestart);
      router.get(uri('period/<period>', version: ver1), onPeriod);

      final String dcache = join(Global.currentPath, '..', 'dcache');
      final Handler index = createStaticHandler(dcache, defaultDocument: Global.indexName);
      final Handler favicon = createStaticHandler(dcache, defaultDocument: Global.faviconName);
      final Handler cascade = Cascade().add(index).add(favicon).add(router.handler).handler;
      final Handler handler = Pipeline().addMiddleware(logRequests()).addHandler(cascade);
      return handler;
    }
    catch (exc) {
      print('$function: $exc');
    }
    finally {
      purge.root = root ?? purge.root;
      purge.count = count ?? purge.count;
      purge.period = period ?? purge.period;
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
