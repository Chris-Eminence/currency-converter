// exchange_rate_state.dart
import 'package:currency_converter/data/model/conversion_model.dart';

class ExchangeRateState {
  final bool isLoading;
  final ExchangeRate? exchangeRate;
  final String? error;
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double convertedAmount;

  ExchangeRateState({
    this.isLoading = false,
    this.exchangeRate,
    this.error,
    this.fromCurrency = 'USD',
    this.toCurrency = 'NGN',
    this.amount = 0.0,
    this.convertedAmount = 0.0,
  });

  ExchangeRateState copyWith({
    bool? isLoading,
    ExchangeRate? exchangeRate,
    String? error,
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? convertedAmount,
  }) {
    return ExchangeRateState(
      isLoading: isLoading ?? this.isLoading,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      error: error ?? this.error,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }
}