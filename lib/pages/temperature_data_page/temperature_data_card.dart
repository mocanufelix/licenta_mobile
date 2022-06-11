import 'package:flutter/material.dart';
import 'package:mobile_client/models/temperature_data.dart';

class TemperatureDataCard extends StatelessWidget {
  final TemperatureData data;

  const TemperatureDataCard({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            "Celsius: ${data.celsius.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.headline6,
          ),
          Text(
            "Fahrenheit: ${data.fahrenheit.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.subtitle1,
          ),
        ],
      ),
    );
  }
}
