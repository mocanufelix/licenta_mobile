import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:mobile_client/constants.dart';
import 'package:mobile_client/models/humidity_data.dart';

class HumidityDataService {
  static Future<List<HumidityData>> getData() async {
    Uri url = Uri.parse("http://${Constants.ip}:3000/humidity-data/");

    Response response = await get(url);

    if (response.statusCode == HttpStatus.ok) {
      var dataList = json.decode(response.body) as List;

      List<HumidityData> humidityDataList = [];

      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];

        HumidityData humidityData = HumidityData(
          (data["humidity"] as num).toDouble(),
        );

        humidityDataList.add(humidityData);
      }

      return humidityDataList;
    } else {
      throw "Eroare la request getData, statusCode: ${response.statusCode}";
    }
  }
}
