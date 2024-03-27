import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path/path.dart';

import 'arb.dart';
import 'loaders/json.dart';
import 'loaders/loader.dart';
import 'loaders/yaml.dart';
import 'options.dart';

const _loaders = <String, Loader>{
  '.arb': JsonLoader(),
  '.json': JsonLoader(),
  '.yaml': YamlLoader(),
  '.yml': YamlLoader(),
};

class ArbGlue {
  final Options options;

  const ArbGlue(this.options);

  void run() {
    options.verify();
    Arb? base;
    for (final folder in options.folders()) {
      final lang = basename(folder.path);
      _log('Processing $lang');

      final arb = Arb(
        locale: lang,
        author: options.author,
        context: options.context,
        entities: <ArbEntity>[],
      );
      base ??= arb;
      for (final file in folder.listSync()) {
        if (file is! File) {
          _log('  - ${file.path}: ⚠️ is not a file.');
          continue;
        }

        final loader = _loaders[extension(file.path)];
        if (loader == null) {
          _log('  ${file.path}: ⚠️ extension is not supported.');
          continue;
        }

        _log('  ${file.path}: start');
        loader.load(file.readAsStringSync(), arb);
      }

      if (arb.locale != base.locale) {
        arb.fallback(base);
      }

      _log('  writing to $lang.arb');
      const encoder = JsonEncoder.withIndent('  ');
      options.write('$lang.arb', encoder.convert(arb.toObject()));
    }
  }

  void _log(String message) {
    if (options.verbose) {
      developer.log(message, name: 'arb_glue');
    }
  }
}
