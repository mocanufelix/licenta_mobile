class TemperatureData {
  double celsius;
  double fahrenheit;
  DateTime time;

  TemperatureData(
    this.celsius,
    this.fahrenheit,
    this.time,
  );

  Map<String, dynamic> toStatisticsData() {
    return {
      "celsius": celsius,
      "time": time,
    };
  }
}
