// currency_converter_page.dart
import 'package:currency_code_to_currency_symbol/currency_code_to_currency_symbol.dart';
import 'package:currency_converter/core/constants/colors.dart';
import 'package:currency_converter/core/constants/dimensions.dart';
import 'package:currency_converter/core/utils/exchange_rate_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/exchange_rate_repo_provider.dart';
import '../widgets/amount_text_field.dart';
import '../widgets/currency_dropdown_button.dart';
import '../widgets/currency_symbol_widget.dart';
import '../widgets/label_text_widget.dart';

class CurrencyConverterPage extends ConsumerStatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  ConsumerState<CurrencyConverterPage> createState() =>
      _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends ConsumerState<CurrencyConverterPage> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController convertedAmountController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch initial rates when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exchangeRateNotifierProvider.notifier).fetchExchangeRates();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    convertedAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exchangeRateNotifierProvider);
    final availableCurrencies = ref.watch(availableCurrenciesProvider);

    // Sync controllers with state
    if (state.amount == 0.0 && amountController.text.isNotEmpty) {
      amountController.clear();
    }
    if (state.convertedAmount == 0.0 &&
        convertedAmountController.text.isNotEmpty) {
      convertedAmountController.clear();
    } else if (state.convertedAmount > 0 &&
        convertedAmountController.text !=
            state.convertedAmount.toStringAsFixed(2)) {
      convertedAmountController.text = state.convertedAmount.toStringAsFixed(2);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFf0f6f6),
      body: Padding(
        padding: const EdgeInsets.all(kPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                'Currency Converter',
                style: GoogleFonts.roboto(
                  fontSize: kTitleFontSize,
                  color: kTitleTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text(
                'Check live rates, set rate alerts, receive \nnotifications and more.',
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  fontSize: kSubtitleFontSize,
                  color: kSubtitleTextColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 41),

            Container(
              padding: const EdgeInsets.all(kPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const LabelTextWidget(text: 'Amount'),
                  Row(
                    children: [
                      CurrencySymbolWidget(currencyCode: state.fromCurrency ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: CurrencyDropdownButton(
                          items: availableCurrencies.isNotEmpty
                              ? availableCurrencies
                              : ['USD', 'EUR', 'GBP', 'NGN'],
                          value: state.fromCurrency,
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(exchangeRateNotifierProvider.notifier)
                                  .setFromCurrency(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AmountTextField(
                          amountController: amountController,
                          onChanged: (value) {
                            ref
                                .read(exchangeRateNotifierProvider.notifier)
                                .setAmount(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: kDividerColor)),
                      Consumer(
                        builder: (context, ref, child) {
                          final animationValue = ref.watch(
                            swapAnimationProvider,
                          );
                          return Transform.rotate(
                            angle: animationValue * 6.28319,
                            // 360 degrees in radians (2 * pi)
                            child: GestureDetector(
                              onTap: () async {
                                await ref
                                    .read(exchangeRateNotifierProvider.notifier)
                                    .swapCurrenciesWithAnimation(ref);
                              },
                              child: Image.asset('assets/icon.png'),
                            ),
                          );
                        },
                      ),
                      Expanded(child: Divider(color: kDividerColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const LabelTextWidget(text: 'Converted Amount'),
                  Row(
                    children: [
                      CurrencySymbolWidget(currencyCode: state.toCurrency ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: CurrencyDropdownButton(
                          items: availableCurrencies.isNotEmpty
                              ? availableCurrencies
                              : ['USD', 'EUR', 'GBP', 'NGN'],
                          value: state.toCurrency,
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(exchangeRateNotifierProvider.notifier)
                                  .setToCurrency(value);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AmountTextField(
                          amountController: convertedAmountController,
                          onChanged: null,
                          readOnly: true,
                        )

                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const LabelTextWidget(text: 'Indicative Exchange Rate'),
            const SizedBox(height: 8),
             state.isLoading ? Row(
               children: [
                 Text('Loading rate...', style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w400,
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                 ),
                  const SizedBox(width: 10),
                 SizedBox(
                   height: 20,
                   width: 20,
                   child: CircularProgressIndicator(
                    color: kTitleTextColor,
                    strokeWidth: 2.5
                   ),
                 ),
               ],
             ) : Text(
               '1 ${state.fromCurrency} =  ${ref.read(exchangeRateNotifierProvider.notifier).getCurrentRate().toStringAsFixed(2)} ${state.toCurrency}',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                fontSize: 18,
                color: Colors.black,
              ),
            ),

            if (state.error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Error: ${state.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
