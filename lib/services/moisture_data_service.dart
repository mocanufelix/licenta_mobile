import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:mobile_client/constants.dart';
import 'package:mobile_client/models/moisture_data.dart';

class MoistureDataService {
  static Future<List<MoistureData>> getData() async {
    Uri url = Uri.parse("http://${Constants.ip}:3000/moisture-data/");

    Response response = await get(url);

    if (response.statusCode == HttpStatus.ok) {
      var dataList = json.decode(response.body) as List;

      List<MoistureData> moistureDataList = [];

      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];

        MoistureData moistureData = MoistureData(
          (data["moisture"] as num).toDouble(),
          DateTime.parse(data["time"]),
        );

        moistureDataList.add(moistureData);
      }

      return moistureDataList;
    } else {
      throw "Eroare la request getData, statusCode: ${response.statusCode}";
    }
  }
}
