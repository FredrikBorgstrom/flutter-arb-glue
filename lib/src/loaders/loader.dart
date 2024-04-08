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

    final prefix = object.remove(r'$prefix');
    _load(object, arb, prefix is String ? prefix : null);
  }

  /// Five ways to load the content.
  ///
  /// 1. nested load
  /// 2. list with text and meta
  /// 3. text with meta
  /// 4. pure text
  void _load(Map<String, dynamic> object, Arb arb, String? prefix) {
    final ck =
        prefix == null ? (String key) => key : (String key) => '$prefix${key[0].toUpperCase()}${key.substring(1)}';

    for (final entry in object.entries) {
      final key = entry.key;
      final value = entry.value;

      // ignore arb meta data
      if (key.startsWith('@')) continue;

      var meta = object['@$key'];

      // 1. nested load
      if (value is Map<String, dynamic>) {
        final prefix2 = value.remove(r'$prefix');
        final nested = prefix2 is String ? prefix2 : key;
        _load(value, arb, ck(nested));
        continue;
      }

      String text;
      if (value is List) {
        // 2. list with text and meta
        meta = {
          if (value.length > 1 && value[1] is String) 'description': value[1],
          if (value.length > 1 && value[1] is Map<String, dynamic>) 'placeholders': value[1],
          if (value.length > 2 && value[2] is String) 'description': value[2],
          if (value.length > 2 && value[2] is Map<String, dynamic>) 'placeholders': value[2],
        };
        text = _parseTextOrSpecial(value[0], meta);
      } else {
        // 3. text with meta
        text = value.toString();
        // 4. pure text
        if (meta is! Map<String, dynamic>) {
          arb.entities.add(ArbEntity(key: ck(key), text: text));
          continue;
        }
      }

      arb.entities.add(ArbEntity(
        key: ck(key),
        text: text,
        description: _parseString(meta, 'description'),
        placeholders: _parsePlaceholders(_parseMap(meta, 'placeholders')),
      ));
    }
  }

  Map<String, dynamic> loadContent(String content);
}

String _parseTextOrSpecial(input, Map<String, dynamic> meta) {
  if (input is String) {
    return input;
  }

  if (input is Map<String, dynamic>) {
    final phs = _parseMap(meta, 'placeholders');
    final key = phs.isEmpty ? '' : phs.keys.first;
    final ph = _parseMap(phs, key);
    final mode = ph['mode'] ?? 'select';
    final text = [for (final entry in input.entries) '${entry.key}{${entry.value}}'].join(' ');
    return '{$key, $mode, $text}';
  }

  return input.toString();
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
      decimalDigits: _parseInt(pm, 'decimalDigits') ?? _parseInt(ph, 'decimalDigits'),
      symbol: _parseString(pm, 'symbol') ?? _parseString(ph, 'symbol'),
      customPattern: _parseString(pm, 'customPattern') ?? _parseString(ph, 'customPattern'),
    );
  }

  return phs;
}
