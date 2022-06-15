class MoistureData {
  double moisture;
  DateTime time;

  MoistureData(
    this.moisture,
    this.time,
  );

  Map<String, dynamic> toStatisticsData() {
    return {
      "moisture": moisture,
      "time": time,
    };
  }
}
