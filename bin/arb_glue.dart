import 'dart:io';

import 'package:arb_glue/arb_glue.dart';
import 'package:yaml/yaml.dart';

void main(List<String> args) {
  final option = Options.fromArgs(args, _loadPubSpec());
  final glue = ArbGlue(option);

  glue.run();
}

Map<String, dynamic> _loadPubSpec() {
  final content = File('pubspec.yaml').readAsStringSync();
  final val = loadYaml(content)['arb_glue'];

  if (val is Map<String, dynamic>) {
    return val;
  }

  return const <String, dynamic>{};
}
