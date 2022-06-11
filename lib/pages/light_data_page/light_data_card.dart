import 'package:flutter/material.dart';
import 'package:mobile_client/models/light_data.dart';

class LightDataCard extends StatelessWidget {
  final LightData data;

  const LightDataCard({
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
            "Light: ${data.light.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
