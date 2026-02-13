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
  String _selectedTimeframe = 'M30';
  List<Candle> _candles = [];
  bool _isLoading = true;
  String? _error;
  
  List<String> _symbols = ['EURUSD']; // Will be loaded from API
  List<String> _filteredSymbols = ['EURUSD']; // For search results
  final TextEditingController _searchController = TextEditingController();
  final List<String> _timeframes = ['M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1'];

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _loadSymbols();
    _loadCandles();
    
    // Auto-refresh every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadCandles(silent: true);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Load available symbols from API
  Future<void> _loadSymbols() async {
    try {
      final response = await http.get(
        Uri.parse('https://server168.liquidityprint.com/wp-json/liquidity/v1/symbols'),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['symbols'] != null) {
          final symbols = (data['symbols'] as List)
              .map((s) {
                // Handle both string and object responses
                if (s is String) return s;
                if (s is Map && s['name'] != null) return s['name'].toString();
                return '';
              })
              .where((s) => s.isNotEmpty)
              .toList();
          
          if (symbols.isNotEmpty) {
            setState(() {
              _symbols = symbols;
              _filteredSymbols = symbols; // Initialize filtered list
            });
          }
        }
      }
    } catch (e) {
      print('Failed to load symbols: $e');
    }
  }

  /// Filter symbols based on search query
  void _filterSymbols(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSymbols = _symbols;
      } else {
        _filteredSymbols = _symbols
            .where((symbol) => symbol.toLowerCase().contains(query.toLowerCase()))
            .toList();
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
        // Toolbar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1929),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Symbol selector with search
              Row(
                children: [
                  // Symbol dropdown
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Symbol',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedSymbol,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0A1929),
                            underline: const SizedBox(),
                            style: const TextStyle(color: Colors.white),
                            items: _filteredSymbols.map((String symbol) {
                              return DropdownMenuItem<String>(
                                value: symbol,
                                child: Text(symbol),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedSymbol = newValue;
                                });
                                _loadCandles();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Timeframe dropdown
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Timeframe',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedTimeframe,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF0A1929),
                            underline: const SizedBox(),
                            style: const TextStyle(color: Colors.white),
                            items: _timeframes.map((String tf) {
                              return DropdownMenuItem<String>(
                                value: tf,
                                child: Text(tf),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTimeframe = newValue;
                                });
                                _loadCandles();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              TextField(
                controller: _searchController,
                onChanged: _filterSymbols,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search symbols...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  prefixIcon: const Icon(Icons.search, color: Colors.cyan),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.cyan.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.cyan),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
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
                            candles: _candles.reversed.toList(), // ✅ Left to right
                          ),
          ),
        ),
      ],
    );
  }
}
