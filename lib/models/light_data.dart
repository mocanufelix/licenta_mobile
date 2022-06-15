class LightData {
  double light;
  DateTime time;

  LightData(
    this.light,
    this.time,
  );

  Map<String, dynamic> toStatisticsData() {
    return {
      "light": light,
      "time": time,
    };
  }
}
