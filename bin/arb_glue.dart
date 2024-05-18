import 'dart:io';

import 'package:arb_glue/arb_glue.dart';
import 'package:arb_glue/src/loaders/yaml.dart';

const version = '1.0.0';

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    // ignore: avoid_print
    print([
      'arb_glue: Generate arb files from the source folder.',
      '',
      'Usage: arb_glue [options]',
      '',
      'Options:',
      Options.getArgParser(args, _loadPubSpec()).usage,
    ].join('\n'));
    return;
  }

  if (args.contains('--version')) {
    // ignore: avoid_print
    print('arb_glue: $version');
    return;
  }
  final option = Options.fromArgs(args, _loadPubSpec());

  ArbGlue(option).run();
}

Map<String, dynamic> _loadPubSpec() {
  const loader = YamlLoader();
  final content = File('pubspec.yaml').readAsStringSync();
  final val = loader.loadContent(content)['arb_glue'];

  if (val is Map<String, dynamic>) {
    return val;
  }

  return const <String, dynamic>{};
}
