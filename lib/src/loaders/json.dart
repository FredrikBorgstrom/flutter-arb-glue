import 'dart:convert';

import 'loader.dart';

class JsonLoader extends Loader {
  const JsonLoader();

  @override
  Map<String, dynamic> loadContent(String content) {
    return jsonDecode(content);
  }
}
