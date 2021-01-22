/// dcache designed by ilshookim
/// MIT License
/// 
/// https://github.com/ilshookim/dcache
/// 
/// working directory:
/// /app                <- working directory
/// /app/dcache         <- program directory
/// /app/dcache/monitor <- monitor directory (default)
/// /app/dcache/mounted <- monitor directory (mounted)
/// 
import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:args/args.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:stack_trace/stack_trace.dart';

import 'global.dart';
import 'api.dart';

void main(List<String> arguments) async {
  final String function = Trace.current().frames[0].member;
  try {
    final ArgParser argParser = ArgParser()
      ..addOption(Global.portOption, abbr: Global.portAbbrOption)
      ..addOption(Global.rootOption, abbr: Global.rootAbbrOption)
      ..addOption(Global.countOption, abbr: Global.countAbbrOption)
      ..addOption(Global.daysOption, abbr: Global.daysAbbrOption)
      ..addOption(Global.timerOption, abbr: Global.timerAbbrOption)
      ..addOption(Global.rootRecursiveOption, abbr: Global.rootRecursiveAbbrOption)
      ..addOption(Global.printAllOption, abbr: Global.printAllAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ?? Platform.environment[Global.portEnvOption] ?? Global.defaultPort;
    final String countOption = argResults[Global.countOption] ?? Platform.environment[Global.countEnvOption] ?? Global.defaultCount;
    final String daysOption = argResults[Global.daysOption] ?? Platform.environment[Global.daysEnvOption] ?? Global.defaultDays;
    final String timerOption = argResults[Global.timerOption] ?? Platform.environment[Global.timerEnvOption] ?? Global.defaultTimer;
    final String printAllOption = argResults[Global.printAllOption] ?? Platform.environment[Global.printAllEnvOption] ?? Global.defaultPrintAll;
    final String rootRecursiveOption = argResults[Global.rootRecursiveOption] ?? Platform.environment[Global.rootRecursiveEnvOption] ?? Global.defaultRootRecursive;
    final String rootOption = argResults[Global.rootOption] ?? Platform.environment[Global.rootEnvOption] ?? Global.defaultRoot;
    final bool rootExists = Directory(rootOption).existsSync();
    final String rootMounted = rootExists ? rootOption : Global.defaultRoot;

    final String host = Global.defaultHost;
    final int port = int.tryParse(portOption);
    final Handler handler = API().v1(
      root: rootMounted, 
      rootRecursive: rootRecursiveOption, 
      count: int.tryParse(countOption), 
      days: int.tryParse(daysOption), 
      timer: int.tryParse(timerOption), 
      printAll: printAllOption,
    );
    final HttpServer server = await serve(handler, host, port);

    final Map pubspec = await Global.pubspec();
    final String name = pubspec[Global.name];
    final String version = pubspec[Global.version];
    final String description = pubspec[Global.description];
    print('$name $version - $description serving at http://${server.address.host}:${server.port}');
    print('purge monitor to $rootMounted using options: root=$rootOption, count=$countOption, days=$daysOption, timer=$timerOption, recursive=$rootRecursiveOption, printAll=$printAllOption');
  }
  catch (exc) {
    print('$function: $exc');
  }
}
