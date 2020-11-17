/// dcache designed by ilshookim
/// MIT License
/// 
/// https://github.com/ilshookim/dcache
/// 
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:dcli/dcli.dart';

import 'global.dart';
import 'api.dart';

/// working directory:
/// /app                <- working directory
/// /app/dcache         <- program directory
/// /app/dcache/monitor <- monitor directory

void main(List<String> arguments) async {
  try {
    final ArgParser argParser = ArgParser()
      ..addOption(Global.portOption, abbr: Global.portAbbrOption)
      ..addOption(Global.rootOption, abbr: Global.rootAbbrOption)
      ..addOption(Global.countOption, abbr: Global.countAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPort;
    final String rootOption = argResults[Global.rootOption] ?? Platform.environment[Global.rootEnvOption] ?? Global.defaultRoot;
    final String countOption = argResults[Global.countOption] ?? Platform.environment[Global.countEnvOption] ?? Global.defaultCount;

    final String host = Global.defaultHost;
    final int port = int.tryParse(portOption);
    final Handler handler = API().v1(root: rootOption, count: int.tryParse(countOption));
    final HttpServer server = await serve(handler, host, port);

    final Map pubspec = await Global.pubspec();
    final String name = pubspec[Global.name];
    final String version = pubspec[Global.version];
    final String description = pubspec[Global.description];
    print('$name $version - $description serving at http://${server.address.host}:${server.port} purging at $rootOption');
  }
  catch (exc) {
    print('main: $exc');
  }
}
