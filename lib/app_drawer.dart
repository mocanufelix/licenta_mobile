import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  void navigateToHumidityData() {
    Navigator.pushNamed(context, "/humidity-data");
  }

  void navigateToLightData() {
    Navigator.pushNamed(context, "/light-data");
  }

  void navigateToMoistureData() {
    Navigator.pushNamed(context, "/moisture-data");
  }

  void navigateToTemperatureData() {
    Navigator.pushNamed(context, "/temperature-data");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(children: [
          ElevatedButton(
            onPressed: navigateToHumidityData,
            child: const Text("Humidity Data"),
          ),
          ElevatedButton(
            onPressed: navigateToLightData,
            child: const Text("Light Data"),
          ),
          ElevatedButton(
            onPressed: navigateToMoistureData,
            child: const Text("Moisture Data"),
          ),
          ElevatedButton(
            onPressed: navigateToTemperatureData,
            child: const Text("Temperature Data"),
          ),
        ]),
      ),
    );
  }
}
