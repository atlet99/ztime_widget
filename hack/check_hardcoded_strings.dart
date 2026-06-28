#!/usr/bin/env dart
///
/// Detects hardcoded user-facing strings in Dart files that should use
/// slang's `context.t` / `t` localization.
///
/// Usage: dart hack/check_hardcoded_strings.dart [directory]
///
/// Exit 0 = clean, 1 = violations found.
///
import 'dart:io';

void main(List<String> args) {
  final dir = args.isNotEmpty ? args[0] : 'lib';
  final Directory target;
  if (dir.startsWith('/')) {
    target = Directory(dir);
  } else {
    target = Directory(dir);
  }

  if (!target.existsSync()) {
    stderr.writeln('ERROR: $dir not found');
    exit(1);
  }

  final violations = <_Violation>[];

  final dartFiles = target
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .where((f) => !f.path.endsWith('.g.dart'))
      .where((f) => !f.path.endsWith('.freezed.dart'))
      .where((f) => !f.path.contains('i18n/'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  for (final file in dartFiles) {
    final lines = file.readAsLinesSync();
    violations.addAll(_scanFile(file.path, lines));
  }

  _printReport(violations);
  exit(violations.isEmpty ? 0 : 1);
}

/// Represents a single hardcoded string violation.
class _Violation {
  _Violation(this.file, this.line, this.column, this.match, this.pattern);

  final String file;
  final int line;
  final int column;
  final String match;
  final String pattern;
}

List<_Violation> _scanFile(String path, List<String> lines) {
  final violations = <_Violation>[];

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final lineNum = i + 1;

    // Skip comments
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('//')) continue;

    // Pattern 1: Text('...') — string literal as first arg
    violations.addAll(_checkTextWidget(line, lineNum, path));

    // Pattern 2: named params with string literals
    violations.addAll(_checkNamedParams(line, lineNum, path));
  }

  return violations;
}

List<_Violation> _checkTextWidget(String line, int lineNum, String path) {
  final violations = <_Violation>[];

  // Match Text('...') or Text("...")
  final textPattern = RegExp(r'''Text\(\s*(['"])((?:(?!\1).)+)\1''');
  for (final match in textPattern.allMatches(line)) {
    final value = match.group(2)!;
    if (_isUserFacing(value)) {
      violations.add(_Violation(
        path,
        lineNum,
        match.start,
        value,
        'Text(...)',
      ));
    }
  }

  return violations;
}

List<_Violation> _checkNamedParams(String line, int lineNum, String path) {
  final violations = <_Violation>[];

  // Named params that carry user-facing text
  final params = [
    'title',
    'label',
    'hint',
    'hintText',
    'tooltip',
    'subtitle',
    'placeholder',
    'buttonText',
    'message',
    'description',
    'text',
    'semanticsLabel',
  ];

  for (final param in params) {
    // Match: param: 'value' or param: "value"
    final pattern = RegExp(
      '''$param\\s*:\\s*(['"])((?:(?!\\1).)+)\\1''',
    );
    for (final match in pattern.allMatches(line)) {
      final value = match.group(2)!;
      if (_isUserFacing(value)) {
        violations.add(_Violation(
          path,
          lineNum,
          match.start,
          value,
          '$param: ...',
        ));
      }
    }
  }

  return violations;
}

/// Determines if a string looks like user-facing text that should be localized.
bool _isUserFacing(String value) {
  if (value.length < 2) return false;

  // Technical strings — not user-facing
  if (value.startsWith('assets/')) return false;
  if (value.startsWith('package:')) return false;
  if (value.startsWith('0x') || value.startsWith('#')) return false;
  if (value.startsWith('android.')) return false;
  if (value.contains('com.')) return false;

  // Locale codes
  if (RegExp(r'^[a-z]{2}(_[A-Z]{2})?$').hasMatch(value)) return false;

  // DateFormat patterns (dd/MM/yyyy, EEEE, etc.)
  if (RegExp(r'^[yMdHhmsEa\s/\-:.,]+$').hasMatch(value)) return false;

  // Enum-style identifiers (PascalCase, no spaces)
  if (RegExp(r'^[A-Z][a-zA-Z0-9]*$').hasMatch(value)) return false;

  // SharedPreferences keys (camelCase/snake_case, no spaces)
  if (!value.contains(' ') &&
      RegExp(r'^[a-z][a-zA-Z0-9_]*$').hasMatch(value)) return false;

  // Method channel / package identifiers
  if (value.contains('.') && value.split('.').length > 2) return false;

  // Task IDs with hyphens
  if (!value.contains(' ') &&
      RegExp(r'^[a-z][a-z0-9\-_]*$').hasMatch(value) &&
      value.contains('-')) return false;

  // Single word lowercase identifiers
  if (!value.contains(' ') &&
      RegExp(r'^[a-z][a-zA-Z0-9_]*$').hasMatch(value)) return false;

  // Must contain at least one space or be a multi-word phrase to be user-facing
  // (exception: short words like "OK", "No", "Yes" that are clearly UI text)
  final knownUiWords = {
    'OK', 'No', 'Yes', 'Cancel', 'Done', 'Save', 'Delete', 'Edit',
    'Back', 'Next', 'Close', 'Open', 'Error', 'Warning', 'Info',
    'Loading', 'Retry', 'None', 'All',
    'ОК', 'Нет', 'Да', 'Отмена', 'Готово', 'Сохранить', 'Удалить',
    'Назад', 'Далее', 'Закрыть', 'Ошибка', 'Загрузка',
  };
  if (knownUiWords.contains(value)) return true;

  // If it has spaces, it's likely user-facing text
  if (value.contains(' ')) return true;

  // If it starts with uppercase and has lowercase, likely a phrase
  if (RegExp(r'^[A-Z][a-z]').hasMatch(value) && value.length > 3) return true;

  return false;
}

void _printReport(List<_Violation> violations) {
  const red = '\x1b[91m';
  const green = '\x1b[92m';
  const yellow = '\x1b[93m';
  const bold = '\x1b[1m';
  const dim = '\x1b[2m';
  const reset = '\x1b[0m';

  print('');
  print('$bold╔══════════════════════════════════════════════════════╗$reset');
  print('$bold║  Hardcoded String Detection                         ║$reset');
  print('$bold╠══════════════════════════════════════════════════════╣$reset');

  if (violations.isEmpty) {
    print('');
    print('  $green${bold}No hardcoded strings found!$reset');
    print('');
    print('$bold╚══════════════════════════════════════════════════════╝$reset');
    return;
  }

  // Group by file
  final byFile = <String, List<_Violation>>{};
  for (final v in violations) {
    byFile.putIfAbsent(v.file, () => []).add(v);
  }

  for (final entry in byFile.entries) {
    final relPath = entry.key.replaceFirst(RegExp(r'^\./'), '');
    print('');
    print('  $red${bold}✗ $relPath$reset');

    for (final v in entry.value) {
      print('    $dim${v.line}:${v.column}$reset ${yellow}${v.pattern}$reset');
      print('      ${v.match}');
    }
  }

  print('');
  print('$bold╠══════════════════════════════════════════════════════╣$reset');
  print('  $red${bold}${violations.length} hardcoded string(s) found$reset');
  print('  $dim Add to lib/i18n/*.i18n.json, use context.t.*$reset');
  print('$bold╚══════════════════════════════════════════════════════╝$reset');
}
