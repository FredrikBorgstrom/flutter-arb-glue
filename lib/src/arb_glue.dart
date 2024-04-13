import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart';

import 'arb.dart';
import 'loaders/json.dart';
import 'loaders/loader.dart';
import 'loaders/yaml.dart';
import 'options.dart';

class ArbGlue {
  final Options options;

  const ArbGlue(this.options);

  void run() {
    options.verify();

    final jsonLoader = JsonLoader(defaultOtherValue: options.defaultOtherValue);
    final yamlLoader = YamlLoader(defaultOtherValue: options.defaultOtherValue);
    final loaders = <String, Loader>{
      '.arb': jsonLoader,
      '.json': jsonLoader,
      '.yaml': yamlLoader,
      '.yml': yamlLoader,
    };

    Arb? base;
    for (final folder in options.folders()) {
      final lang = basename(folder.path);
      Logger.root.info('=== Start language $lang ===');

      final arb = Arb(
        locale: lang,
        author: options.author,
        context: options.context,
        entities: <String, ArbEntity>{},
      );
      base ??= arb;
      for (final file in folder.listSync()) {
        if (file is! File) {
          Logger.root.warning('${file.path}: is not a file.');
          continue;
        }

        final loader = loaders[extension(file.path)];
        if (loader == null) {
          Logger.root.warning('${file.path}: extension is not supported.');
          continue;
        }

        loader.load(file.readAsStringSync(), arb, base);
        Logger.root.info('${file.path}: ok');
      }

      if (arb.locale != base.locale) {
        arb.fallback(base);
      }

      const encoder = JsonEncoder.withIndent('  ');
      options.write(
        lang,
        encoder.convert(arb.toObject(
          lastModified: options.lastModified,
        )),
      );
    }
  }
}
