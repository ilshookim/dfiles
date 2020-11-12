import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:args/args.dart';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

Future<Map> getYaml() async {
  final String name = 'pubspec.yaml';
  final String path = join(dirname(Platform.script.toFilePath()), '../$name');
  final File file = new File(path);
  final String text = await file.readAsString();
  final Map yaml = loadYaml(text);
  return yaml;
}

Response getHello(Request request) {
  return Response.ok('hello: "${request.url}"');
}

Response getUser(Request reqeust, String user) {
    return Response.ok('hello $user');
}

void main(List<String> arguments) async {
  Map yaml = await getYaml();
  final String appName = yaml['name'];
  final String appDesc = yaml['description'];
  final String appVer = yaml['version'];
  print('$appName $appVer - $appDesc');

  final ArgParser argParser = ArgParser()..addOption('port', abbr: 'p');
  final ArgResults argResults = argParser.parse(arguments);
  final String argPort = argResults['port'] ?? Platform.environment['PORT'] ?? '8080';
  final int port = int.tryParse(argPort);

  if (port == null) {
    print('Could not parse port value "$argPort" into a number.');
    exitCode = 64; // command line usage error
    return;
  }

  final Router app = Router()
    ..get('/hello', getHello)
    ..get('/user/<user>', getUser);

  final String localhost = 'localhost';
  final server = await serve(app.handler, localhost, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

/// 1.1 turn off auto formatting
/// 1.2 dcli added to pubspec.yaml
/// 1.3 omit_local_variable_types added to analysis_options.yaml
///
/// 2.1 read yaml
/// 2.2 print app, ver, desc
///
/// 3.1 shelf added to pubspec.yaml
/// 3.2 shelf_router added to pubspec.yaml
/// 
