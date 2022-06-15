import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:mobile_client/constants.dart';
import 'package:mobile_client/models/light_data.dart';

class LightDataService {
  static Future<List<LightData>> getData() async {
    Uri url = Uri.parse("http://${Constants.ip}:3000/light-data/");

    Response response = await get(url);

    if (response.statusCode == HttpStatus.ok) {
      var dataList = json.decode(response.body) as List;

      List<LightData> lightDataList = [];

      for (int i = 0; i < dataList.length; i++) {
        var data = dataList[i];

        LightData lightData = LightData(
          (data["light"] as num).toDouble(),
          DateTime.parse(data["time"]),
        );

        lightDataList.add(lightData);
      }

      return lightDataList;
    } else {
      throw "Eroare la request getData, statusCode: ${response.statusCode}";
    }
  }
}
