
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

// Your existing ExchangeRate model with slight modification
class ExchangeRate {
  final String baseCode;
  final List<String> currencies;
  final Map<String, double> conversionRates;
  final String? result;

  ExchangeRate({
    required this.currencies,
    required this.baseCode,
    required this.conversionRates,
    this.result,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    final rates = (json['conversion_rates'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    // Extract currencies from the conversion rates
    final currenciesList = rates.keys.toList()..sort();

    return ExchangeRate(
      baseCode: json['base_code'],
      conversionRates: rates,
      currencies: currenciesList,
      result: json['result'],
    );
  }
}