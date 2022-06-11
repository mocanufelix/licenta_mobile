import 'package:flutter/material.dart';
import 'package:mobile_client/models/moisture_data.dart';

class MoistureDataCard extends StatelessWidget {
  final MoistureData data;

  const MoistureDataCard({
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
            "Moisture: ${data.moisture.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
