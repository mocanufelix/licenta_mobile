import 'package:flutter/material.dart';
import 'package:mobile_client/pages/humidity_data_page/humidity_data_page.dart';
import 'package:mobile_client/pages/light_data_page/light_data_page.dart';
import 'package:mobile_client/pages/moisture_data_page/moisture_data_page.dart';
import 'package:mobile_client/pages/temperature_data_page/temperature_data_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "/humidity-data",
      routes: {
        "/temperature-data": (context) => const TemperatureDataPage(),
        "/humidity-data": (context) => const HumidityDataPage(),
        "/light-data": (context) => const LightDataPage(),
        "/moisture-data": (context) => const MoistureDataPage(),
      },
    );
  }
}
