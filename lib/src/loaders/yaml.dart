import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import 'loader.dart';

class YamlLoader extends Loader {
  const YamlLoader({super.defaultOtherValue = ''});

  @override
  Map<String, dynamic> loadContent(String content) {
    final YamlMap value = loadYaml(content);
    final encoded = jsonEncode(
      value,
      toEncodable: (nonEncodable) {
        final node = nonEncodable as YamlNode;
        Logger.root.info('failed to load from(line:column) '
            '${node.span.start.line}:${node.span.start.column}'
            ' to '
            '${node.span.end.line}:${node.span.end.column} '
            '(which will be ignored) '
            'with source: "${node.span.text.replaceAll('\n', '\\n')}"');
        return null;
      },
    );
    final result = jsonDecode(encoded);
    return result is Map<String, dynamic> ? result : <String, dynamic>{};
  }
}
