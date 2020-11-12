import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class Global {
  static final String spec = 'pubspec.yaml';
  static final String localhost = 'localhost';
  static final String port = '8080';
  static final int exitCodeCommandLineUsageError = 64;
}

Future<Map> getYaml() async {
  final String path = join(dirname(Platform.script.toFilePath()), '../${Global.spec}');
  final File file = new File(path);
  final String text = await file.readAsString();
  final Map yaml = loadYaml(text);
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

  final String path = join(dirname(Platform.script.toFilePath()), '.');
  final Handler index = createStaticHandler(path, defaultDocument: 'index.html');
  final Handler favicon = createStaticHandler(path, defaultDocument: 'favicon.ico');
  final Handler handler = Cascade().add(index).add(favicon).add(api.handler).handler;

  final ArgParser argParser = ArgParser()..addOption('port', abbr: 'p');
  final ArgResults argResults = argParser.parse(arguments);
  final String argPort = argResults['port'] ?? Platform.environment['DCACHE_PORT'] ?? Global.port;

  final String host = Global.localhost;
  final int port = int.tryParse(argPort);
  final server = await serve(handler, host, port);

  final Map yaml = await getYaml();
  final String appName = yaml['name'];
  final String appDesc = yaml['description'];
  final String appVer = yaml['version'];
  final String hostIp = server.address.host;
  final int hostPort = server.port;
  print('$appName $appVer - $appDesc serving at http://$hostIp:$hostPort');
}
