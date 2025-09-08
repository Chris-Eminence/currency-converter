// Description: Service to fetch exchange rates and available currencies from ExchangeRate-API with enhanced debugging.

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/conversion_model.dart';

class ExchangeRateService {
  static const String _baseUrl = 'https://v6.exchangerate-api.com/v6';
  // static final String _apiKey = const String.fromEnvironment('API_KEY');
  static final String _apiKey = '8f3d6cb3730087fdb7a841e2';

  static Future<ExchangeRate> getExchangeRates(String baseCurrency) async {
    print('api key: $_apiKey');
    try {
      final url = Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency');
      print('🌐 API Call: $url');

      final response = await http.get(url);

      // Print the raw response for debugging
      print('📥 Response Status: ${response.statusCode}');
      print('📦 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        // Print the parsed JSON structure
        print('✅ API Result: ${jsonData['result']}');
        print('🏦 Base Currency: ${jsonData['base_code']}');
        print('💰 Number of Conversion Rates: ${(jsonData['conversion_rates'] as Map).length}');

        if (jsonData['result'] == 'success') {
          // Extract currencies from conversion_rates keys
          final rates = jsonData['conversion_rates'] as Map<String, dynamic>;
          final currenciesList = rates.keys.toList();

          // Print sample currencies for verification
          print('📋 Available Currencies (first 10): ${currenciesList.take(10).toList()}');
          print('📋 Total Currencies: ${currenciesList.length}');

          return ExchangeRate(
            baseCode: jsonData['base_code'],
            conversionRates: rates.map((key, value) => MapEntry(key, (value as num).toDouble())),
            currencies: currenciesList,
          );
        } else {
          print('❌ API Error: ${jsonData['error-type']}');
          throw Exception('API returned error: ${jsonData['error-type']}');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to load exchange rates: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Exception: $e');
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
    print('🧪 Testing API connection...');
    try {
      final url = Uri.parse('$_baseUrl/$_apiKey/latest/$baseCurrency');
      print('🔗 Testing URL: $url');

      final response = await http.get(url);
      print('📊 Test Response Status: ${response.statusCode}');
      print('📄 Test Response Body Length: ${response.body.length} characters');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('🎯 Test Successful - API Result: ${jsonData['result']}');
      } else {
        print('💥 Test Failed - Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Test Exception: $e');
    }
  }
}