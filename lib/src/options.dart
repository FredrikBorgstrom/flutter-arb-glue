import 'dart:io';

import 'package:args/args.dart';
import 'package:path/path.dart';

/// The options for the arb glue.
class Options {
  /// The source folder contains the files.
  final String source;

  /// The destination folder where the files will be generated.
  final String destination;

  /// Blacklisted folders inside the [source].
  final List<String> exclude;

  /// The base locale of the arb file.
  ///
  /// If not provided, the base locale will be the first locale found in the
  /// source folder.
  final String? base;

  /// The author of the arb file.
  final String? author;

  /// The context of the arb file.
  final String? context;

  /// Whether to print verbose output.
  final bool verbose;

  const Options({
    required this.source,
    required this.destination,
    this.exclude = const [],
    this.base,
    this.author,
    this.context,
    this.verbose = false,
  });

  factory Options.fromArgs(List<String> args, Map<String, dynamic> o) {
    final src = o['source'] is String ? o['source'] : 'lib/l10n';
    final dst = o['destination'] is String ? o['destination'] : 'lib/l10n';
    final base = o['base'] is String ? o['base'] : null;
    final author = o['author'] is String ? o['author'] : null;
    final context = o['context'] is String ? o['context'] : null;
    final verbose = o['verbose'] is bool ? o['verbose'] : false;
    final exc = o['exclude'];
    final exclude = exc is Iterable ? exc.cast<String>() : <String>[];

    final parser = ArgParser()
      ..addOption('source', abbr: 's', defaultsTo: src)
      ..addOption('destination', abbr: 'd', defaultsTo: dst)
      ..addMultiOption('exclude', abbr: 'e', defaultsTo: exclude)
      ..addOption('base', abbr: 'b', defaultsTo: base)
      ..addOption('author', defaultsTo: author)
      ..addOption('context', defaultsTo: context)
      ..addFlag('verbose', abbr: 'v', defaultsTo: verbose);
    final result = parser.parse(args);

    return Options(
      source: result['source'],
      destination: result['destination'],
      exclude: result['exclude'],
      base: result['base'],
      author: result['author'],
      context: result['context'],
      verbose: result['verbose'],
    );
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
    final all = Directory(source).listSync();
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

  void write(String file, String content) {
    File(join(destination, file)).writeAsStringSync(content);
  }
}
