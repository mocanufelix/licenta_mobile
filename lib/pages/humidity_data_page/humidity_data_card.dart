import 'package:flutter/material.dart';
import 'package:mobile_client/models/humidity_data.dart';

class HumidityDataCard extends StatelessWidget {
  final HumidityData data;

  const HumidityDataCard({
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
            "Humidity: ${data.humidity.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
