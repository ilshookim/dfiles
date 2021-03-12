/// dcache designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/dcache
///
/// working directory:
/// /app         <- working directory
/// /app/monitor <- monitor directory (default)
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
  final String function = Trace.current().frames[0].member!;
  try {
    final ArgParser argParser = ArgParser()
      ..addOption(Global.portOption, abbr: Global.portAbbrOption)
      ..addOption(Global.countOption, abbr: Global.countAbbrOption)
      ..addOption(Global.daysOption, abbr: Global.daysAbbrOption)
      ..addOption(Global.timerOption, abbr: Global.timerAbbrOption)
      ..addOption(Global.monitorOption, abbr: Global.monitorAbbrOption)
      ..addOption(Global.monitorRecursiveOption,
          abbr: Global.monitorRecursiveAbbrOption)
      ..addOption(Global.printAllOption, abbr: Global.printAllAbbrOption);
    final ArgResults argResults = argParser.parse(arguments);
    final String portOption = argResults[Global.portOption] ??
        Platform.environment[Global.portEnvOption] ??
        Global.defaultPort;
    final String countOption = argResults[Global.countOption] ??
        Platform.environment[Global.countEnvOption] ??
        Global.defaultCount;
    final String daysOption = argResults[Global.daysOption] ??
        Platform.environment[Global.daysEnvOption] ??
        Global.defaultDays;
    final String timerOption = argResults[Global.timerOption] ??
        Platform.environment[Global.timerEnvOption] ??
        Global.defaultTimer;
    final String printAllOption = argResults[Global.printAllOption] ??
        Platform.environment[Global.printAllEnvOption] ??
        Global.defaultPrintAll;
    final String monitorOption = argResults[Global.monitorOption] ??
        Platform.environment[Global.monitorEnvOption] ??
        Global.defaultMonitor;
    final String monitorRecursiveOption =
        argResults[Global.monitorRecursiveOption] ??
            Platform.environment[Global.rootRecursiveEnvOption] ??
            Global.defaultRootRecursive;

    final String host = Global.defaultHost;
    final int port = int.tryParse(portOption)!;
    final Handler handler = API().v1(
      monitor: absolute(monitorOption),
      monitorRecursive: monitorRecursiveOption,
      count: int.tryParse(countOption)!,
      days: int.tryParse(daysOption)!,
      timer: int.tryParse(timerOption)!,
      printAll: printAllOption,
    );
    final HttpServer server = await serve(handler, host, port);

    final Map pubspec = await Global.pubspec();
    final String name = pubspec[Global.name];
    final String version = pubspec[Global.version];
    final String description = pubspec[Global.description];
    print(
        '$name $version - $description serving at http://${server.address.host}:${server.port}');
    print(
        'options: monitor=$monitorOption, count=$countOption, days=$daysOption, timer=$timerOption, recursive=$monitorRecursiveOption, printAll=$printAllOption');
  } catch (exc) {
    print('$function: $exc');
  }
}
