// exchange_rate_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/animation_utils.dart';
import '../../core/utils/exchange_rate_state.dart';
import '../../data/data_source/currency_api.dart';
import '../../data/model/conversion_model.dart';

// providers.dart
final exchangeRateNotifierProvider =
    StateNotifierProvider<ExchangeRateNotifier, ExchangeRateState>((ref) {
      return ExchangeRateNotifier();
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

class ExchangeRateNotifier extends StateNotifier<ExchangeRateState> {
  ExchangeRateNotifier() : super(ExchangeRateState());

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

  // Enhanced swap method
  // Future<void> swapCurrenciesWithAnimation(WidgetRef ref) async {
  //   if (state.fromCurrency == state.toCurrency) return;
  //
  //   // Simple animation without complex utils
  //   final animationController = ref.read(swapAnimationProvider.notifier);
  //
  //   // Animate from 0 to 1 over 300ms
  //   const duration = Duration(milliseconds: 300);
  //   const interval = Duration(milliseconds: 16);
  //   final steps = duration.inMilliseconds ~/ interval.inMilliseconds;
  //
  //   for (int i = 0; i <= steps; i++) {
  //     await Future.delayed(interval);
  //     animationController.state = i / steps;
  //   }
  //
  //   // PERFORM SWAP AFTER ANIMATION COMPLETES
  //   _performSwap();
  //
  //   // Fetch new rates for the NEW base currency
  //   await fetchExchangeRates(state.fromCurrency);
  //
  //   // Reset animation
  //   animationController.state = 0.0;
  // }

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

    // Now set the amount to the previously converted value
    // and let the normal conversion logic handle the recalculation
    if (previousConvertedAmount > 0) {
      state = state.copyWith(amount: previousConvertedAmount);
      // The _convertAmount() will be called automatically after state update
    }

    // Reset converted amount to trigger recalculation
    state = state.copyWith(convertedAmount: 0.0);
  }

  // Also update your regular swapCurrencies method to use the same logic:
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

    // Now set the amount to the previously converted value
    if (previousConvertedAmount > 0) {
      state = state.copyWith(amount: previousConvertedAmount);
    }

    // Reset converted amount to trigger recalculation
    state = state.copyWith(convertedAmount: 0.0);

    // Fetch rates for the new base currency
    fetchExchangeRates(newFromCurrency);
  }
}
