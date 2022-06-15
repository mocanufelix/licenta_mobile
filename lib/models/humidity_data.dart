class HumidityData {
  double humidity;
  DateTime time;

  HumidityData(
    this.humidity,
    this.time,
  );

  Map<String, dynamic> toStatisticsData() {
    return {
      "humidity": humidity,
      "time": time,
    };
  }
}
