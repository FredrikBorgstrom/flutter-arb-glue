import 'dart:convert';
import 'dart:io';

import 'package:arb_glue/arb_glue.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';

void main() {
  late final Directory temp;
  setUpAll(() {
    temp = Directory.systemTemp.createTempSync('arb_glue');
  });

  tearDownAll(() {
    temp.deleteSync(recursive: true);
  });

  test('All features', () {
    final enPath = join(temp.path, 'en');
    final zhPath = join(temp.path, 'zh');
    final frPath = join(temp.path, 'fr');
    Directory(enPath).createSync();
    Directory(zhPath).createSync();
    Directory(frPath).createSync();
    File(join(enPath, 'wrong.ext')).writeAsStringSync('test');
    Directory(join(enPath, 'sub-dir')).createSync();
    File(join(enPath, 'basic.yaml')).writeAsStringSync('''"@@context": global
plain: Plain text
yamlCustom:
  text: YAML custom
  description: YAML custom with description
withDescription: With description
"@withDescription":
  description: "With description"''');
    File(join(enPath, 'feature.yml')).writeAsStringSync('''"@@context": feature
withPlaceholders:
  text: YAML custom with {placeholder1} {placeholder2}
  description: YAML custom with placeholders with description
  placeholders:
    placeholder1:
      type: String
      description: Placeholder 1
      example: Example 1
    placeholder2:
      type: Number
      description: Placeholder 2
      example: 100
      format: compactCurrency
      optionalParameters:
        symbol: '@'
        customPattern: '0,0.00'
        decimalDigits: 2
allTypePlaceholders: test {k1} {k2} {k3} {k4} {k5} {k6}
'@allTypePlaceholders':
  description: test
  placeholders:
    k1: {type: INT}
    k2: {type: Integer}
    k3: {type: Double}
    k4: {type: Number}
    k5: {type: DateTime}
    k6: {type: NotExist}''');
    File(join(zhPath, 'feature.arb'))
        .writeAsStringSync('''{"@@context": "feature",
"withPlaceholders":{
  "text": "YAML 客製化 {placeholder1} {placeholder2}",
  "description": "特殊說明",
  "placeholders":{
    "placeholder1":{
      "description": "特殊說明"}}},
"allTypePlaceholders": "測試 {k1} {k2} {k3} {k4} {k5} {k6}"
}''');
    File(join(frPath, 'basic.arb')).writeAsStringSync('''{
  "plain": "test"
}''');

    ArbGlue(Options.fromArgs([
      '--source',
      temp.path,
      '--destination',
      temp.path,
      '--base',
      'en',
      '--author',
      'evan.lu',
      '--context',
      'arb_glue',
      '--exclude',
      'fr',
      '--verbose',
    ], {})).run();

    final en = jsonDecode(File(join(temp.path, 'en.arb')).readAsStringSync());
    (en as Map).remove('@@last_modified');
    expect(en, {
      "@@locale": "en",
      "@@author": "evan.lu",
      "@@context": "arb_glue",
      "plain": "Plain text",
      "yamlCustom": "YAML custom",
      "@yamlCustom": {"description": "YAML custom with description"},
      "withDescription": "With description",
      "@withDescription": {"description": "With description"},
      "featureWithPlaceholders":
          "YAML custom with {placeholder1} {placeholder2}",
      "@featureWithPlaceholders": {
        "description": "YAML custom with placeholders with description",
        "placeholders": {
          "placeholder1": {
            "type": "String",
            "description": "Placeholder 1",
            "example": "Example 1"
          },
          "placeholder2": {
            "type": "num",
            "description": "Placeholder 2",
            "format": "compactCurrency",
            "optionalParameters": {
              "decimalDigits": 2,
              "symbol": "@",
              "customPattern": "0,0.00"
            }
          }
        }
      },
      "featureAllTypePlaceholders": "test {k1} {k2} {k3} {k4} {k5} {k6}",
      "@featureAllTypePlaceholders": {
        "description": "test",
        "placeholders": {
          "k1": {"type": "int"},
          "k2": {"type": "int"},
          "k3": {"type": "double"},
          "k4": {"type": "num"},
          "k5": {"type": "DateTime"},
          "k6": {"type": "String"}
        }
      }
    });

    final zh = jsonDecode(File(join(temp.path, 'zh.arb')).readAsStringSync());
    (zh as Map).remove('@@last_modified');
    expect(zh, {
      "@@locale": "zh",
      "@@author": "evan.lu",
      "@@context": "arb_glue",
      "featureWithPlaceholders": "YAML 客製化 {placeholder1} {placeholder2}",
      "@featureWithPlaceholders": {
        "description": "特殊說明",
        "placeholders": {
          "placeholder1": {
            "type": "String",
            "description": "特殊說明",
            "example": "Example 1"
          },
          "placeholder2": {
            "type": "num",
            "description": "Placeholder 2",
            "format": "compactCurrency",
            "optionalParameters": {
              "decimalDigits": 2,
              "symbol": "@",
              "customPattern": "0,0.00"
            }
          }
        }
      },
      "featureAllTypePlaceholders": "測試 {k1} {k2} {k3} {k4} {k5} {k6}",
      "@featureAllTypePlaceholders": {
        "description": "test",
        "placeholders": {
          "k1": {"type": "int"},
          "k2": {"type": "int"},
          "k3": {"type": "double"},
          "k4": {"type": "num"},
          "k5": {"type": "DateTime"},
          "k6": {"type": "String"}
        }
      }
    });

    expect(File(join(temp.path, 'fr.arb')).existsSync(), false);
  });

  group('Options validation', () {
    test('empty', () {
      const options = Options(source: '', destination: '');
      expect(() => options.verify(), throwsArgumentError);
    });

    test('empty', () {
      final options = Options(
        source: temp.path,
        destination: '/some/not/exist/path',
      );
      expect(() => options.verify(), throwsArgumentError);
    });
  });
}
