import '../arb.dart';

/// The loader interface.
///
/// It should be called to load the file.
abstract class Loader {
  /// Constant.
  const Loader();

  /// Load the content of the file.
  ///
  /// - [content] is the content of the file.
  /// - [arb] is used for multiple arb files and merge the result into one object.
  void load(String content, Arb arb) {
    final object = loadContent(content);
    final context = _parseString(object, '@@context');
    final k = context == null || context == 'global'
        ? (String key) => key
        : (String key) => '$context${key[0].toUpperCase()}${key.substring(1)}';

    for (final entry in object.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key.startsWith('@')) continue;

      var info = object['@$key'];
      if (info is! Map<String, dynamic> && value is String) {
        arb.entities.add(ArbEntity(key: k(key), text: value));
        continue;
      }

      late final String text;
      if (value is Map<String, dynamic>) {
        text = value.remove('text');
        info = value;
      } else if (value is List) {
        text = value[0];
        info = {
          if (value.length > 1 && value[1] is String) 'description': value[1],
          if (value.length > 1 && value[1] is Map) 'placeholders': value[1],
          if (value.length > 2 && value[2] is String) 'description': value[2],
          if (value.length > 2 && value[2] is Map) 'placeholders': value[2],
        };
      } else {
        text = value;
      }

      arb.entities.add(ArbEntity(
        key: k(key),
        text: text,
        description: _parseString(info, 'description'),
        placeholders: _parsePlaceholders(_parseMap(info, 'placeholders')),
      ));
    }
  }

  Map<String, dynamic> loadContent(String content);
}

String? _parseString(Map<String, dynamic> object, String key) {
  final v = object[key];
  if (v is String?) return v;

  return null;
}

int? _parseInt(Map<String, dynamic> object, String key) {
  final v = object[key];
  if (v is int?) return v;

  return null;
}

Map<String, dynamic> _parseMap(Map<String, dynamic> object, String key) {
  final v = object[key];
  if (v is Map<String, dynamic>) return v;

  return <String, dynamic>{};
}

Map<String, ArbPlaceholder> _parsePlaceholders(Map<String, dynamic> data) {
  final phs = <String, ArbPlaceholder>{};
  for (final phEntry in data.entries) {
    final ph = phEntry.value;
    if (ph is! Map<String, dynamic>) continue;

    final pm = _parseMap(ph, 'optionalParameters');
    phs[phEntry.key] = ArbPlaceholder(
      type: ArbEntityType.fromString(_parseString(ph, 'type')),
      description: _parseString(ph, 'description'),
      example: _parseString(ph, 'example'),
      format: _parseString(ph, 'format'),
      decimalDigits: _parseInt(pm, 'decimalDigits'),
      symbol: _parseString(pm, 'symbol'),
      customPattern: _parseString(pm, 'customPattern'),
    );
  }

  return phs;
}
