import 'dart:io';

import 'package:args/args.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';

/// The options for the arb glue.
class Options {
  /// The source folder contains the files.
  final String source;

  final String? secondarySource;

  /// The destination folder where the files will be generated.
  final String destination;

  /// Blacklisted folders inside the [source].
  final List<String> exclude;

  /// The fallback values of the arb file.
  final String? base;

  /// The default value of other in select/plural mode.
  final String defaultOtherValue;

  /// The author of these messages.
  final String? author;

  /// It describes (in text) the context in which all these resources apply.
  final String? context;

  /// Whether to add the last modified time of the file.
  final bool lastModified;

  /// The file template for the output arb file.
  final String fileTemplate;

  /// Whether to print verbose output.
  final bool verbose;

  const Options({
    required this.source,
    required this.destination,
    this.secondarySource,
    this.exclude = const [],
    this.base,
    this.defaultOtherValue = 'UNKNOWN',
    this.lastModified = true,
    this.author,
    this.context,
    this.fileTemplate = '{lang}.arb',
    this.verbose = false,
  });

  static ArgParser getArgParser(List<String> args, Map<String, dynamic> o) {
    final src = o['source'] is String ? o['source'] : 'lib/l10n';
    final secondarySrc =
        o['secondarySource'] is String ? o['secondarySource'] : null;
    final dst = o['destination'] is String ? o['destination'] : 'lib/l10n';
    final base = o['base'] is String ? o['base'] : null;
    final defaultOtherValue =
        o['defaultOtherValue'] is String ? o['defaultOtherValue'] : 'UNKNOWN';
    final author = o['author'] is String ? o['author'] : null;
    final context = o['context'] is String ? o['context'] : null;
    final lastModified = o['lastModified'] is bool ? o['lastModified'] : true;
    final fileTemplate =
        o['fileTemplate'] is String ? o['fileTemplate'] : '{lang}.arb';
    final verbose = o['verbose'] is bool ? o['verbose'] : false;
    final exc = o['exclude'];
    final exclude = exc is Iterable ? exc.cast<String>() : <String>[];

    final parser = ArgParser()
      ..addOption('source', abbr: 's', defaultsTo: src)
      ..addOption('secondarySource', defaultsTo: secondarySrc)
      ..addOption('destination', abbr: 'd', defaultsTo: dst)
      ..addMultiOption('exclude', abbr: 'e', defaultsTo: exclude)
      ..addOption('base', abbr: 'b', defaultsTo: base)
      ..addOption('defaultOtherValue', defaultsTo: defaultOtherValue)
      ..addFlag('lastModified', defaultsTo: lastModified)
      ..addOption('author', defaultsTo: author)
      ..addOption('context', defaultsTo: context)
      ..addOption('fileTemplate', defaultsTo: fileTemplate)
      ..addFlag('verbose', abbr: 'v', defaultsTo: verbose);

    return parser;
  }

  factory Options.fromArgs(List<String> args, Map<String, dynamic> o) {
    final parsed = getArgParser(args, o).parse(args);
    final options = Options(
      source: parsed['source'],
      secondarySource: parsed['secondarySource'],
      destination: parsed['destination'],
      exclude: parsed['exclude'],
      base: parsed['base'],
      defaultOtherValue: parsed['defaultOtherValue'],
      author: parsed['author'],
      context: parsed['context'],
      lastModified: parsed['lastModified'],
      fileTemplate: parsed['fileTemplate'],
      verbose: parsed['verbose'],
    );

    Logger.root.level = options.verbose ? Level.ALL : Level.WARNING;
    // ignore: avoid_print
    Logger.root.onRecord.listen((record) => print(record.message));
    Logger.root
        .info(parsed.options.map((key) => '$key: ${parsed[key]}').join('\n'));

    return options;
  }

  void verify() {
    String? error = _verifyFolder(source);
    if (error != null) {
      throw ArgumentError('The source $error');
    }

    error = _verifyFolder(destination);
    if (error != null) {
      throw ArgumentError('The destination $error');
    }
  }

  String? _verifyFolder(String folder) {
    if (folder.isEmpty) {
      return 'folder cannot be empty.';
    }

    if (!Directory(folder).existsSync()) {
      return 'folder does not exist.';
    }

    return null;
  }

  Iterable<Directory> folders() sync* {
    yield* _folders(source);
  }

  Iterable<File> files() sync* {
    yield* _files(source);
  }

  Iterable<File> secondaryFiles() sync* {
    if (secondarySource != null) {
      yield* _files(secondarySource!);
    }
  }

  Iterable<Directory> secondaryFolders() sync* {
    if (secondarySource != null) {
      yield* _folders(secondarySource!);
    }
  }

  Iterable<Directory> _folders(String dir) sync* {
    final all = Directory(dir).listSync();
    Iterable<Directory> filtered = all
        .where((e) => e is Directory && !exclude.contains(basename(e.path)))
        .cast<Directory>();

    if (base != null) {
      for (final e in filtered) {
        if (basename(e.path) == base) {
          yield e;
        }
      }

      filtered = filtered.where((e) => basename(e.path) != base);
    }
    yield* filtered;
  }

  _files(String dir) sync* {
    final all = Directory(dir).listSync();
    yield* all.where((e) => e is File && e.path.endsWith('.arb')).cast<File>();
  }

  void write(String lang, String content) {
    final file = fileTemplate.replaceAll('{lang}', lang);
    Logger.root.info('writing to ${join(destination, file)}');
    File(join(destination, file)).writeAsStringSync(content);
  }
}
