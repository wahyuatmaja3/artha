import 'package:flutter_test/flutter_test.dart';

import 'package:artha/core/utils/transaction_text_parser.dart';

void main() {
  final parser = TransactionTextParser();

  test('parse expense simple input', () {
    final result = parser.parse(
      'beli batagor 10000',
      now: DateTime(2026, 5, 23),
    );

    expect(result, isNotNull);
    expect(result!.type, 'expense');
    expect(result.amount, 10000);
    expect(result.note, 'batagor');
    expect(result.date, DateTime(2026, 5, 23));
  });

  test('parse expense with rb suffix', () {
    final result = parser.parse('jajan kopi susu 15rb');

    expect(result, isNotNull);
    expect(result!.type, 'expense');
    expect(result.amount, 15000);
    expect(result.note, 'kopi susu');
  });

  test('parse income with jt suffix', () {
    final result = parser.parse('gaji bulanan 3jt');

    expect(result, isNotNull);
    expect(result!.type, 'income');
    expect(result.amount, 3000000);
    expect(result.note, 'bulanan');
  });

  test('parse thousand separator format', () {
    final result = parser.parse('bayar listrik 250.000');

    expect(result, isNotNull);
    expect(result!.amount, 250000);
    expect(result.note, 'listrik');
  });

  test('return null when amount missing', () {
    final result = parser.parse('beli bakso');
    expect(result, isNull);
  });
}
