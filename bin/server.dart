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
  static final String spec = 'pubspec.yaml';
  static final String localhost = '0.0.0.0';
  static final String port = '8088';
  static final String currentPath = dirname(Platform.script.toFilePath());
  static final int exitCodeCommandLineUsageError = 64;
}

Future<Map> configInfo() async {
  Map yaml = Map();
  try {
    final String path = join(Global.currentPath, '../${Global.spec}');
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
  final Router api = Router();

  api.get('/users/<userName>/whoami', (Request request) async {
    final String userName = params(request, 'userName');
    return Response.ok('You are ${userName}');
  });

  api.get('/users/<userName>/say-hello', (Request request, String userName) async {
    return Response.ok('Hello ${userName}');
  });

  final String path = join(Global.currentPath, '.');
  final Handler index = createStaticHandler(path, defaultDocument: 'index.html');
  final Handler favicon = createStaticHandler(path, defaultDocument: 'favicon.ico');
  final Handler cascade = Cascade().add(index).add(favicon).add(api.handler).handler;

  final ArgParser argParser = ArgParser()..addOption('port', abbr: 'p');
  final ArgResults argResults = argParser.parse(arguments);
  final String portOption = argResults['port'] ?? Platform.environment['DCACHE_PORT'] ?? Global.port;

  final String host = Global.localhost;
  final int port = int.tryParse(portOption);
  final Handler handler = const Pipeline().addMiddleware(logRequests()).addHandler(cascade);
  final HttpServer server = await serve(handler, host, port);

  final Map config = await configInfo();
  final String appName = config['name'];
  final String appDesc = config['description'];
  final String appVer = config['version'];
  print('$appName $appVer - $appDesc serving at http://${server.address.host}:${server.port}');
}
