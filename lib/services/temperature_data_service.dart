import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:mobile_client/constants.dart';
import 'package:mobile_client/models/temperature_data.dart';

class TemperatureDataService {
  static Future<List<TemperatureData>> getData() async {
    Uri url = Uri.parse("http://${Constants.ip}:3000/temperature-data/");

    Response response = await get(url);

    if (response.statusCode == HttpStatus.ok) {
      var dataList = json.decode(response.body) as List;

      List<TemperatureData> temperatureDataList = [];

      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];

        TemperatureData temperatureData = TemperatureData(
          (data["celsius"] as num).toDouble(),
          (data["fahrenheit"] as num).toDouble(),
          DateTime.parse(data["time"]),
        );

        temperatureDataList.add(temperatureData);
      }

      return temperatureDataList;
    } else {
      throw "Error la request getData, statusCode: ${response.statusCode}";
    }
  }
}
