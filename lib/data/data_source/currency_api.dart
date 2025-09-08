// Description: Service to fetch exchange rates and available currencies from ExchangeRate-API with enhanced debugging.

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../model/conversion_model.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';
  // static final String _apiKey = const String.fromEnvironment('API_KEY');
  static final String _apiKey = '8f3d6cb3730087fdb7a841e2';

  static Future<ExchangeRate> getExchangeRates(String baseCurrency) async {
    try {
      final url = Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency');

      final response = await http.get(url);


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);


        if (jsonData['result'] == 'success') {
          // Extract currencies from conversion_rates keys
          final rates = jsonData['conversion_rates'] as Map<String, dynamic>;
          final currenciesList = rates.keys.toList();


          return ExchangeRate(
            baseCode: jsonData['base_code'],
            conversionRates: rates.map((key, value) => MapEntry(key, (value as num).toDouble())),
            currencies: currenciesList,
          );
        } else {
          debugPrint('❌ API Error: ${jsonData['error-type']}');
          throw Exception('API returned error: ${jsonData['error-type']}');
        }
      } else {
        debugPrint('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      throw Exception('Failed to fetch exchange rates: $e');
    }
  }

  // Helper method to get all available currencies from a specific base
  static Future<List<String>> getAvailableCurrencies(String baseCurrency) async {
    print('🔄 Fetching available currencies for base: $baseCurrency');
    final exchangeRate = await getExchangeRates(baseCurrency);
    print('✅ Retrieved ${exchangeRate.currencies.length} currencies');
    return exchangeRate.currencies;
  }

  // Additional debug method to test the API connection
  static Future<void> testApiConnection(String baseCurrency) async {
    debugPrint('🧪 Testing API connection...');
    try {
      final url = Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency');
      debugPrint('🔗 Testing URL: $url');

      final response = await http.get(url);
      debugPrint('📊 Test Response Status: ${response.statusCode}');
      debugPrint('📄 Test Response Body Length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        debugPrint('🎯 Test Successful - API Result: ${jsonData['result']}');
      } else {
        debugPrint('💥 Test Failed - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('💥 Test Exception: $e');
    }
  }
}