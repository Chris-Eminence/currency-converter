import 'package:currency_converter/core/utils/exchange_rate_state.dart';
import 'package:currency_converter/data/model/conversion_model.dart';
import 'package:currency_converter/presentation/viewmodels/exchange_rate_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// providers.dart
final exchangeRateNotifierProvider =
StateNotifierProvider<ExchangeRateViewmodel, ExchangeRateState>((ref) {
  return ExchangeRateViewmodel();
});

// Provider for the exchange rate data
final exchangeRateProvider = Provider<ExchangeRate?>((ref) {
  return ref.watch(exchangeRateNotifierProvider).exchangeRate;
});

// Provider for the swap animation value
final swapAnimationProvider = StateProvider<double>((ref) => 0.0);

// Provider for available currencies
final availableCurrenciesProvider = Provider<List<String>>((ref) {
  final exchangeRate = ref.watch(exchangeRateProvider);
  return exchangeRate?.currencies ?? [];
});

// Provider for loading state
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(exchangeRateNotifierProvider).isLoading;
});

// Provider for error state
final errorProvider = Provider<String?>((ref) {
  return ref.watch(exchangeRateNotifierProvider).error;
});

// Provider for from currency
final fromCurrencyProvider = Provider<String>((ref) {
  return ref.watch(exchangeRateNotifierProvider).fromCurrency;
});

// Provider for to currency
final toCurrencyProvider = Provider<String>((ref) {
  return ref.watch(exchangeRateNotifierProvider).toCurrency;
});

// Provider for converted amount
final convertedAmountProvider = Provider<double>((ref) {
  return ref.watch(exchangeRateNotifierProvider).convertedAmount;
});

// Provider for current rate display
final currentRateProvider = Provider<double>((ref) {
  final state = ref.watch(exchangeRateNotifierProvider);
  return state.exchangeRate?.conversionRates[state.toCurrency] ?? 0.0;
});
