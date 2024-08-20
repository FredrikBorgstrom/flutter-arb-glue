import 'dart:convert';
import 'dart:io';

// import 'package:logging/logging.dart';
// import 'package:path/path.dart';

import 'arb.dart';
import 'loaders/json.dart';
import 'loaders/loader.dart';
import 'loaders/yaml.dart';
import 'options.dart';

main(List<String> args) {
  const options = Options(
      source: 'lib/l10n_parts',
      destination: 'lib/l10n_merged',
      fileTemplate: "intl_{lang}.arb");

  const arbGlue = ArbGlue(options);
  arbGlue.run();
}

class ArbGlue {
  final Options options;

  const ArbGlue(this.options);

  Future<void> run() async {
    final directory = Directory.current;
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

    final files = options.files().toList();

    if (options.secondarySource != null) {
      final secondaryFiles = options.secondaryFiles();
      files.addAll(secondaryFiles);
    }

    final Map<String, Map<String, dynamic>> localeMap = {};

    for (var file in files) {
      final content = await File(file.path).readAsString();
      final Map<String, dynamic> jsonContent = json.decode(content);

      final locale = jsonContent['@@locale'];
      if (locale != null) {
        if (!localeMap.containsKey(locale)) {
          localeMap[locale] = {};
        }
        localeMap[locale]?.addAll(jsonContent);
      }
    }

    for (var locale in localeMap.keys) {
      final mergedContent = json.encode(localeMap[locale]);
      final outputFile = File('${directory.path}/$locale.arb');
      await outputFile.writeAsString(mergedContent);
    }
  }
}

/* void run() {
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

        Logger.root.info(file.path);
        loader.load(file.readAsStringSync(), arb, base);
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
  } */