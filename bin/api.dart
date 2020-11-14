import 'package:path/path.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

import 'global.dart';
import 'purge.dart';

class API {
  static Handler get v1 {
    try {
      final Router api = Router();
      final Purge purge = Purge(autostart: true);

      api.get('/start', (Request request) async {
        final bool succeed = purge.start();
        final bool running = purge.isRunning;
        return Response.ok('purge: start=$succeed, running=$running');
      });

      api.get('/stop', (Request request) async {
        final bool succeed = purge.stop();
        final bool running = purge.isRunning;
        return Response.ok('purge: stop=$succeed, running=$running');
      });

      final String path = join(Global.currentPath, '.');
      final Handler index = createStaticHandler(path, defaultDocument: Global.indexName);
      final Handler favicon = createStaticHandler(path, defaultDocument: Global.faviconName);
      final Handler cascade = Cascade().add(index).add(favicon).add(api.handler).handler;
      final Handler handler = Pipeline().addMiddleware(logRequests()).addHandler(cascade);
      return handler;
    }
    catch (exc) {
      print('v1: exc=$exc');
    }
    final Handler defaultHandler = Pipeline().addHandler((Request request) {
      return Response.ok('Request for ${request.url}');
    });
    return defaultHandler;
  }
}
