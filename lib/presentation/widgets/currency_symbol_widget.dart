import 'package:currency_code_to_currency_symbol/currency_code_to_currency_symbol.dart';
import 'package:currency_converter/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CurrencySymbolWidget extends StatelessWidget {
  const CurrencySymbolWidget({
    super.key,
    required this.currencyCode,
  });

  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: kTitleTextColor,
      child: CurrencyToSymbolWidget(
        currencyCode: currencyCode,
        textStyle: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}