/// dcache designed by ilshookim
/// MIT License
/// 
/// https://github.com/ilshookim/dcache
/// 
import 'dart:io';

import 'package:path/path.dart';
import 'package:yaml/yaml.dart';

class Global {
  static final String defaultHost = '0.0.0.0';
  static final String defaultPort = '8088';
  static final String defaultRoot = './dcache/monitor';
  static final String portOption = 'port';
  static final String portAbbrOption = 'p';
  static final String portEnvOption = 'DCACHE_PORT';
  static final String rootOption = 'root';
  static final String rootAbbrOption = 'r';
  static final String rootEnvOption = 'DCACHE_ROOT';

  static final String indexName = 'index.html';
  static final String faviconName = 'favicon.ico';
  static final int exitCodeCommandLineUsageError = 64;

  static final String currentPath = dirname(Platform.script.toFilePath());
  static final String yamlName = 'pubspec.yaml';
  static final String name = 'name';
  static final String version = 'version';
  static final String description = 'description';
  
  static Future<Map> pubspec() async {
    Map yaml = Map();
    try {
      final String path = join(Global.currentPath, '../$yamlName');
      final File file = new File(path);
      final String text = await file.readAsString();
      yaml = loadYaml(text);
    }
    catch (exc) {
      print('configInfo: $exc');
    }
    return yaml;
  }
}
