import 'dart:convert';

import 'package:yaml/yaml.dart';

import 'loader.dart';

class YamlLoader extends Loader {
  const YamlLoader();

  @override
  Map<String, dynamic> loadContent(String content) {
    final value = loadYaml(content);
    return jsonDecode(jsonEncode(value));
  }
}
