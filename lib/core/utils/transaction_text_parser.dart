class ParsedTransactionInput {
  final String type;
  final double amount;
  final String note;
  final DateTime date;

  const ParsedTransactionInput({
    required this.type,
    required this.amount,
    required this.note,
    required this.date,
  });
}

class TransactionTextParser {
  static const Set<String> _expenseKeywords = {
    'beli',
    'bayar',
    'jajan',
    'pesen',
    'order',
    'isi',
    'topup',
    'transfer',
    'traktir',
  };

  static const Set<String> _incomeKeywords = {
    'gaji',
    'bonus',
    'dapat',
    'dapet',
    'terima',
    'jual',
    'fee',
    'komisi',
    'cashback',
  };

  ParsedTransactionInput? parse(String rawInput, {DateTime? now}) {
    final input = rawInput.trim();
    if (input.isEmpty) return null;

    final amount = _extractAmount(input);
    if (amount == null || amount <= 0) return null;

    final tokens = _tokenize(input);
    final type = _detectType(tokens);
    final note = _buildNote(input);
    final date = now ?? DateTime.now();

    return ParsedTransactionInput(
      type: type,
      amount: amount,
      note: note,
      date: DateTime(date.year, date.month, date.day),
    );
  }

  double? _extractAmount(String input) {
    final pattern = RegExp(r'(\d[\d.,]*\s*(?:rb|ribu|jt|juta)?)', caseSensitive: false);
    final matches = pattern.allMatches(input);
    if (matches.isEmpty) return null;

    final rawAmount = matches.last.group(0);
    if (rawAmount == null) return null;
    return _normalizeAmount(rawAmount);
  }

  double? _normalizeAmount(String rawAmount) {
    var lower = rawAmount.toLowerCase().replaceAll(' ', '');

    var multiplier = 1.0;
    if (lower.endsWith('rb') || lower.endsWith('ribu')) {
      multiplier = 1000;
      lower = lower.replaceAll(RegExp(r'(rb|ribu)$'), '');
    } else if (lower.endsWith('jt') || lower.endsWith('juta')) {
      multiplier = 1000000;
      lower = lower.replaceAll(RegExp(r'(jt|juta)$'), '');
    }

    if (lower.contains('.') && lower.contains(',')) {
      lower = lower.replaceAll('.', '').replaceAll(',', '.');
    } else if (lower.contains('.')) {
      if (RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(lower)) {
        lower = lower.replaceAll('.', '');
      }
    } else if (lower.contains(',')) {
      if (RegExp(r'^\d{1,3}(,\d{3})+$').hasMatch(lower)) {
        lower = lower.replaceAll(',', '');
      } else {
        lower = lower.replaceAll(',', '.');
      }
    }

    final parsed = double.tryParse(lower);
    if (parsed == null) return null;
    return parsed * multiplier;
  }

  List<String> _tokenize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  String _detectType(List<String> tokens) {
    for (final token in tokens) {
      if (_incomeKeywords.contains(token)) return 'income';
      if (_expenseKeywords.contains(token)) return 'expense';
    }
    return 'expense';
  }

  String _buildNote(String input) {
    var note = input;
    note = note.replaceAll(RegExp(r'\d[\d.,]*\s*(rb|ribu|jt|juta)?', caseSensitive: false), ' ');
    note = note.replaceAll(RegExp(r'\s+'), ' ').trim();

    final words = note.split(' ').where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '';

    if (_expenseKeywords.contains(words.first.toLowerCase()) ||
        _incomeKeywords.contains(words.first.toLowerCase())) {
      words.removeAt(0);
    }

    return words.join(' ').trim();
  }
}
