/// The arb file.
class Arb {
  /// The language of the arb file.
  ///
  /// Should set by `@@locale`
  final String locale;

  /// The context of the arb file.
  ///
  /// This will add prefix on the key after merged, for example:
  ///
  /// ```json
  /// {
  ///   "@@context": "myAwesomeFeature",
  ///   "myKey": "myValue"
  /// }
  /// ```
  ///
  /// will have the entry: `"myAwesomeFeatureMyKey": "myValue"`
  ///
  /// Should set by `@@context`
  final String? context;

  /// The author of the arb file.
  ///
  /// Should set by `@@author`
  final String? author;

  /// All the entities in the arb file.
  final Map<String, ArbEntity> entities;

  const Arb({
    required this.locale,
    required this.context,
    required this.author,
    required this.entities,
  });

  Map<String, Object> toObject({
    required bool lastModified,
  }) {
    final obj = <String, Object>{
      '@@locale': locale,
      if (lastModified) '@@last_modified': DateTime.now().toUtc().toIso8601String(),
    };

    if (author != null) {
      obj['@@author'] = author!;
    }
    if (context != null) {
      obj['@@context'] = context!;
    }

    for (final entity in entities.values) {
      obj.addAll(entity.toObject());
    }

    return obj;
  }

  void fallback(Arb base) {
    for (final entity in entities.values) {
      final b = base.entities[entity.key];
      if (b != null) {
        entity.fallback(b);
      }
    }
  }
}

/// The entity of the arb file.
class ArbEntity {
  /// The key of the entity.
  ///
  /// It will be render as the function(getter) name after generate from l10n.
  final String key;

  /// The text of the entity.
  ///
  /// It will be render as the value after generate from l10n.
  final String text;

  /// The description of the entity.
  ///
  /// It will be render as comment after generate from l10n.
  String? description;

  /// The placeholders of the entity.
  ///
  /// It mostly used for plural, for example: `You have {count} messages`
  Map<String, ArbPlaceholder>? placeholders;

  ArbEntity({
    required this.key,
    required this.text,
    this.placeholders,
    this.description,
  });

  Map<String, Object> toObject() {
    final obj = <String, Object>{key: text};

    final info = <String, Object>{};
    if (description != null) {
      info['description'] = description!;
    }
    if (placeholders?.isNotEmpty == true) {
      info['placeholders'] = {for (final entry in placeholders!.entries) entry.key: entry.value.toObject()};
    }
    if (info.isNotEmpty) {
      obj['@$key'] = info;
    }

    return obj;
  }

  void fallback(ArbEntity base) {
    description ??= base.description;
    if (placeholders == null) {
      placeholders = base.placeholders;
      return;
    }

    final phs = base.placeholders ?? <String, ArbPlaceholder>{};
    for (final entry in phs.entries) {
      final ph = placeholders![entry.key];
      if (ph == null) {
        placeholders![entry.key] = entry.value;
        continue;
      }

      ph.fallback(entry.value);
    }
  }
}

/// Placeholder of the entity, used for formatting.
class ArbPlaceholder {
  /// The data type of the placeholder.
  final ArbEntityType type;

  /// The description of the placeholder.
  ///
  /// It will be render as comment after generate from l10n.
  String? description;

  /// The example of the placeholder.
  String? example;

  /// The format of the placeholder.
  ///
  /// For example:
  ///
  /// - `compactCurrency`
  /// - `decimalPattern`
  /// - `MMMEd`
  /// - `yMMMEd`
  ///
  /// See implement in:
  ///
  /// - DateTime https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html
  /// - Number https://pub.dev/documentation/intl/latest/intl/NumberFormat-class.html
  String? format;

  /// Use for currency, compactCurrency and compactSimpleCurrency in optionalParameters
  int? decimalDigits;

  /// Use for currency and compactCurrency in optionalParameters
  String? symbol;

  /// Use for currency in optionalParameters
  ///
  /// see https://pub.dev/documentation/intl/latest/intl/NumberFormat/NumberFormat.currency.html
  String? customPattern;

  ArbPlaceholder({
    required this.type,
    this.description,
    this.example,
    this.format,
    this.decimalDigits,
    this.symbol,
    this.customPattern,
  });

  Map<String, Object> toObject() {
    final obj = <String, Object>{'type': type.target};
    if (description != null) {
      obj['description'] = description!;
    }
    if (example != null) {
      obj['example'] = example!;
    }
    if (format != null) {
      obj['format'] = format!;
    }

    final optionalParameters = <String, Object>{};
    if (decimalDigits != null) {
      optionalParameters['decimalDigits'] = decimalDigits!;
    }
    if (symbol != null) {
      optionalParameters['symbol'] = symbol!;
    }
    if (customPattern != null) {
      optionalParameters['customPattern'] = customPattern!;
    }

    if (optionalParameters.isNotEmpty) {
      obj['optionalParameters'] = optionalParameters;
    }

    return obj;
  }

  void fallback(ArbPlaceholder base) {
    description ??= base.description;
    example ??= base.example;
    format ??= base.format;
    decimalDigits ??= base.decimalDigits;
    symbol ??= base.symbol;
    customPattern ??= base.customPattern;
  }
}

/// The data type of the entity.
enum ArbEntityType {
  string("String"),
  integer("int"),
  double("double"),
  number("num"),
  dateTime("DateTime");

  /// The target to render in the generated file.
  final String target;

  const ArbEntityType(this.target);

  factory ArbEntityType.fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'int':
      case 'integer':
        return integer;
      case 'float':
      case 'double':
        return double;
      case 'num':
      case 'number':
        return number;
      case 'date':
      case 'time':
      case 'datetime':
        return dateTime;
      default:
        return string;
    }
  }
}
