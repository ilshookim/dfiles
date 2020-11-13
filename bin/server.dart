import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';
import 'package:dcli/dcli.dart';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class Global {
  static final String currentPath = dirname(Platform.script.toFilePath());
  static final String pubspecName = 'pubspec.yaml';
  static final String index = 'index.html';
  static final String favicon = 'favicon.ico';

  static final String portOption = 'port';
  static final String portAbbrOption = 'p';
  static final String portEnvOption = 'DCACHE_PORT';

  static final String defaultHost = '0.0.0.0';
  static final String defaultPort = '8088';

  static final String name = 'name';
  static final String version = 'version';
  static final String description = 'description';

  static final int exitCodeCommandLineUsageError = 64;
}

Future<Map> configInfo() async {
  Map yaml = Map();
  try {
    final String path = join(Global.currentPath, '../${Global.pubspecName}');
    final File file = new File(path);
    final String text = await file.readAsString();
    yaml = loadYaml(text);
  }
  catch (exc) {
    print('configInfo: exc=$exc');
  }
  return yaml;
}

void main(List<String> arguments) async {
  try {
    final Router api = Router();

    api.get('/users/<userName>/whoami', (Request request) async {
      final String userName = params(request, 'userName');
      return Response.ok('You are ${userName}');
    });

    api.get('/users/<userName>/say-hello', (Request request, String userName) async {
      return Response.ok('Hello ${userName}');
    });

    final String path = join(Global.currentPath, '.');
    final Handler index = createStaticHandler(path, defaultDocument: Global.index);
    final Handler favicon = createStaticHandler(path, defaultDocument: Global.favicon);
    final Handler cascade = Cascade().add(index).add(favicon).add(api.handler).handler;

    final ArgParser argParser = ArgParser()..addOption(Global.portOption, abbr: Global.portAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPort;

    final String host = Global.defaultHost;
    final int port = int.tryParse(portOption);
    final Handler handler = const Pipeline().addMiddleware(logRequests()).addHandler(cascade);
    final HttpServer server = await serve(handler, host, port);

    final Map config = await configInfo();
    final String appName = config[Global.name];
    final String appDesc = config[Global.description];
    final String appVer = config[Global.version];
    print('$appName $appVer - $appDesc serving at http://${server.address.host}:${server.port}');
  }
  catch (exc) {
    print('dcache: exc=$exc');
  }
}
