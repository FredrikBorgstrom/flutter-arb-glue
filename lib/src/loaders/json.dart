import 'dart:convert';

import 'loader.dart';

class JsonLoader extends Loader {
  const JsonLoader({required super.defaultOtherValue});

  @override
  Map<String, dynamic> loadContent(String content) {
    final result = jsonDecode(content);
    return result is Map<String, dynamic> ? result : <String, dynamic>{};
  }
}
