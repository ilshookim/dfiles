/// dcache designed by ilshookim
/// MIT License
///
/// https://github.com/ilshookim/dcache
///
import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';
import 'package:stack_trace/stack_trace.dart';

class Global {
  static final String defaultApp = 'DCACHE';
  static final String defaultHost = '0.0.0.0';
  static final String defaultPort = '8088';
  static final String defaultMonitor = 'monitor';
  static final String defaultCount = '0';
  static final String defaultDays = '0';
  static final String defaultTimer = '0';
  static final String defaultRootRecursive = 'true';
  static final String defaultPrintAll = 'true';
  static final String portOption = 'port';
  static final String portAbbrOption = 'p';
  static final String portEnvOption = '${defaultApp}_PORT';
  static final String monitorOption = 'monitor';
  static final String monitorAbbrOption = 'r';
  static final String monitorEnvOption = '${defaultApp}_MONITOR';
  static final String countOption = 'count';
  static final String countAbbrOption = 'c';
  static final String countEnvOption = '${defaultApp}_COUNT';
  static final String daysOption = 'days';
  static final String daysAbbrOption = 'd';
  static final String daysEnvOption = '${defaultApp}_DAYS';
  static final String timerOption = 'timer';
  static final String timerAbbrOption = 'e';
  static final String timerEnvOption = '${defaultApp}_TIMER';
  static final String monitorRecursiveOption = 'recursive';
  static final String monitorRecursiveAbbrOption = 'u';
  static final String rootRecursiveEnvOption = '${defaultApp}_RECURSIVE';
  static final String printAllOption = 'print';
  static final String printAllAbbrOption = 't';
  static final String printAllEnvOption = '${defaultApp}_PRINT_ALL';

  static final String indexName = 'index.html';
  static final String faviconName = 'favicon.ico';
  static final int exitCodeCommandLineUsageError = 64;

  static final String currentPath = dirname(Platform.script.toFilePath());
  static final String yamlName = 'pubspec.yaml';
  static final String name = 'name';
  static final String version = 'version';
  static final String description = 'description';

  static Future<Map> pubspec() async {
    final String function = Trace.current().frames[0].member;
    Map yaml = Map();
    try {
      final String path = join(current, yamlName);
      final File file = new File(path);
      final String text = await file.readAsString();
      yaml = loadYaml(text);
    } catch (exc) {
      print('$function: $exc');
    }
    return yaml;
  }
}

extension BoolParsing on String {
  bool parseBool() {
    final String lowerCase = this.toLowerCase();
    if (lowerCase.isEmpty || lowerCase == 'false') return false;
    return lowerCase == 'true' || lowerCase != '0';
  }
}
