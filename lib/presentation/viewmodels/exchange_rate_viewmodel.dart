import 'package:currency_converter/presentation/viewmodels/data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/exchange_rate_state.dart';
import '../../data/data_source/currency_api.dart';


class ExchangeRateViewmodel extends StateNotifier<ExchangeRateState> {
  ExchangeRateViewmodel() : super(ExchangeRateState());

  // Fetch exchange rates
  Future<void> fetchExchangeRates([String? baseCurrency]) async {
    final effectiveBaseCurrency = baseCurrency ?? state.fromCurrency;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final exchangeRate = await ExchangeRateService.getExchangeRates(
        effectiveBaseCurrency,
      );
      state = state.copyWith(
        isLoading: false,
        exchangeRate: exchangeRate,
        fromCurrency: effectiveBaseCurrency,
      );
      _convertAmount(); // Convert with new rates
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Set from currency
  void setFromCurrency(String currency) {
    state = state.copyWith(fromCurrency: currency);
    fetchExchangeRates(currency);
  }

  // Set to currency
  void setToCurrency(String currency) {
    state = state.copyWith(toCurrency: currency);
    _convertAmount(); // Re-convert with new target currency
  }

  // Set amount and convert
  void setAmount(String amountText) {
    final amount = double.tryParse(amountText) ?? 0.0;
    state = state.copyWith(amount: amount);
    _convertAmount();
  }

  // Perform conversion
  void _convertAmount() {
    if (state.amount == 0.0) {
      // Reset to 0 when amount is 0
      state = state.copyWith(convertedAmount: 0.0);
      return;
    }

    if (state.exchangeRate != null && state.amount > 0) {
      final rate = state.exchangeRate!.conversionRates[state.toCurrency];
      if (rate != null) {
        final convertedAmount = state.amount * rate;
        state = state.copyWith(convertedAmount: convertedAmount);
        return;
      }
    }
    state = state.copyWith(convertedAmount: 0.0);
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Get current exchange rate for display
  double getCurrentRate() {
    return state.exchangeRate?.conversionRates[state.toCurrency] ?? 0.0;
  }

  Future<void> swapCurrenciesWithAnimation(WidgetRef ref) async {
    if (state.fromCurrency == state.toCurrency) return;

    final animationController = ref.read(swapAnimationProvider.notifier);

    // Use a cancelable animation approach
    bool isCanceled = false;

    // Animate from 0 to 1 over 300ms
    const duration = Duration(milliseconds: 300);
    const interval = Duration(milliseconds: 16);
    final steps = duration.inMilliseconds ~/ interval.inMilliseconds;

    for (int i = 0; i <= steps; i++) {
      // Check if we should cancel the animation
      if (isCanceled) break;

      await Future.delayed(interval);

      // Check again before updating state
      if (!isCanceled) {
        animationController.state = i / steps;
      }
    }

    // Only perform swap if not canceled
    if (!isCanceled) {
      _performSwap();
      await fetchExchangeRates(state.fromCurrency);
    }

    // Reset animation if not canceled
    if (!isCanceled) {
      animationController.state = 0.0;
    }
  }
  void _performSwap() {
    if (state.fromCurrency == state.toCurrency) return;

    // Store the current converted amount before swapping currencies
    final previousConvertedAmount = state.convertedAmount;

    // Swap the currencies first
    final String newFromCurrency = state.toCurrency;
    final String newToCurrency = state.fromCurrency;

    state = state.copyWith(
      fromCurrency: newFromCurrency,
      toCurrency: newToCurrency,
    );

    // Set the amount to the previously converted value and let the normal conversion logic handle the recalculation
    if (previousConvertedAmount > 0) {
      state = state.copyWith(amount: previousConvertedAmount);
      // The _convertAmount() will be called automatically after state update
    }

    // Reset converted amount to trigger recalculation
    state = state.copyWith(convertedAmount: 0.0);
  }

  // Update regular swapCurrencies method to use same logic:
  void swapCurrencies() {
    if (state.fromCurrency == state.toCurrency) return;

    // Store the current converted amount before swapping currencies
    final previousConvertedAmount = state.convertedAmount;

    // Swap the currencies first
    final String newFromCurrency = state.toCurrency;
    final String newToCurrency = state.fromCurrency;

    state = state.copyWith(
      fromCurrency: newFromCurrency,
      toCurrency: newToCurrency,
    );

    // Set the amount to the previously converted value
    if (previousConvertedAmount > 0) {
      state = state.copyWith(amount: previousConvertedAmount);
    }

    // Reset converted amount to trigger recalculation
    state = state.copyWith(convertedAmount: 0.0);

    // Fetch rates for the new base currency
    fetchExchangeRates(newFromCurrency);
  }
}
