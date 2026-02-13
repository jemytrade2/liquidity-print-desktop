import 'package:flutter/material.dart';
import 'package:candlesticks/candlesticks.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/candle.dart' as app_candle;

class ChartWidget extends StatefulWidget {
  const ChartWidget({Key? key}) : super(key: key);

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  final ApiService _apiService = ApiService();
  
  String _selectedSymbol = 'EURUSD';
  String _selectedTimeframe = 'M1';
  List<Candle> _candles = [];
  bool _isLoading = true;
  String? _error;
  
  List<String> _symbols = ['EURUSD']; // Will be loaded from API
  final List<String> _timeframes = ['M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1'];

  late Timer _timer; // Added for periodic polling

  @override
  void initState() {
    super.initState();
    _loadSymbols(); // Load symbol list first
    _loadCandles();
    
        _loadCandles(silent: true);
        _startPolling();
      }
    });
  }


  Future<void> _loadCandles({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // Notify WordPress that we're viewing this symbol (so EA knows to stream it)
      await _notifyActiveSymbol();
      
      final data = await _apiService.getCandles(_selectedSymbol, _selectedTimeframe);
      
      if (data['success'] == true) {
        final history = data['history'] as List?;
        
        if (history != null && history.isNotEmpty) {
          setState(() {
            _candles = history.map((candle) {
              return Candle(
                date: DateTime.fromMillisecondsSinceEpoch(candle['t'] * 1000),
                open: (candle['o'] as num).toDouble(),
                high: (candle['h'] as num).toDouble(),
                low: (candle['l'] as num).toDouble(),
                close: (candle['c'] as num).toDouble(),
                volume: (candle['v'] as num).toDouble(),
              );
            }).toList();
            _isLoading = false;
          });
        } else if (!silent) {
          setState(() {
            _isLoading = false;
            _error = 'No data available. Make sure MT5 EA is running.';
          });
        }
      }
    } catch (e) {
      if (!silent) {
        setState(() {
          _isLoading = false;
          _error = 'Error loading data: $e';
        });
      }
    }
  }

  /// Notify WordPress about the active symbol being viewed
  Future<void> _notifyActiveSymbol() async {
    try {
      await _apiService.setActiveSymbol(_selectedSymbol, _selectedTimeframe);
    } catch (e) {
      print('Failed to notify active symbol: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls Bar
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Symbol Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                ),
                child: DropdownButton<String>(
                  value: _selectedSymbol,
                  dropdownColor: const Color(0xFF061E32),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  underline: Container(),
                  items: _symbols.map((symbol) {
                    return DropdownMenuItem(
                      value: symbol,
                      child: Text(symbol),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedSymbol = newValue;
                      });
                      _loadCandles(); // This will notify WordPress via _notifyActiveSymbol
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Timeframe Buttons
              ..._timeframes.map((tf) {
                final isSelected = tf == _selectedTimeframe;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedTimeframe = tf;
                      });
                      _loadCandles();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.black.withOpacity(0.5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      minimumSize: const Size(50, 32),
                    ),
                    child: Text(tf, style: const TextStyle(fontSize: 12)),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        
        // Chart Area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF061E32),
                  Colors.black,
                ],
              ),
            ),
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.cyan),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadCandles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _candles.isEmpty
                        ? const Center(
                            child: Text(
                              'Waiting for data...\nMake sure MT5 EA is attached to a chart',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70),
                            ),
                          )
                        : Candlesticks(
                            candles: _candles,
                          ),
          ),
        ),
      ],
    );
  }
}
