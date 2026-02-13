class Candle {
  final int timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double buyVolume;
  final double sellVolume;

  Candle({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.buyVolume,
    required this.sellVolume,
  });

  factory Candle.fromJson(Map<String, dynamic> json) {
    return Candle(
      timestamp: json['timestamp'] as int,
      open: (json['open_price'] as num).toDouble(),
      high: (json['high_price'] as num).toDouble(),
      low: (json['low_price'] as num).toDouble(),
      close: (json['close_price'] as num).toDouble(),
      volume: (json['volume'] as num).toDouble(),
      buyVolume: (json['buy_volume'] as num).toDouble(),
      sellVolume: (json['sell_volume'] as num).toDouble(),
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
}
