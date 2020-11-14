import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf_io.dart';

import 'api.dart';
import 'global.dart';

void main(List<String> arguments) async {
  try {
    final ArgParser argParser = ArgParser()..addOption(Global.portOption, abbr: Global.portAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPort;

    final String host = Global.defaultHost;
    final int port = int.tryParse(portOption);
    final HttpServer server = await serve(API().v1, host, port);

    final Map pubspec = await Global.pubspec();
    final String name = pubspec[Global.name];
    final String version = pubspec[Global.version];
    final String description = pubspec[Global.description];
    print('$name $version - $description serving at http://${server.address.host}:${server.port}');
  }
  catch (exc) {
    print('main: exc=$exc');
  }
}
