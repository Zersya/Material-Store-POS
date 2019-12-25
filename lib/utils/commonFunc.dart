import 'package:flutter_money_formatter/flutter_money_formatter.dart';

FlutterMoneyFormatter fmf = new FlutterMoneyFormatter(
    amount: 0,
    settings: MoneyFormatterSettings(
        symbol: 'Rp. ',
        thousandSeparator: '.',
        decimalSeparator: ',',
        symbolAndNumberSeparator: ' ',
        fractionDigits: 0,
        compactFormatType: CompactFormatType.short),
  );