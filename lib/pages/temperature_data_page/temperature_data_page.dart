import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/models/temperature_data.dart';
import 'package:mobile_client/pages/temperature_data_page/temperature_data_card.dart';
import 'package:mobile_client/services/temperature_data_service.dart';
import '../../app_drawer.dart';
import '../../models/temperature_data.dart';
import 'temperature_data_card.dart';

class TemperatureDataPage extends StatefulWidget {
  const TemperatureDataPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TemperatureDataPageState();
  }
}

class _TemperatureDataPageState extends State<TemperatureDataPage> {
  Timer? timer;
  TemperatureData? temperatureData;
  List<TemperatureData>? temperatureDataList;
  int startTimeMinutes = 0;

  Future<void> makeGetTemperatureDataRequest() async {
    List<TemperatureData> newTemperatureDataList = await TemperatureDataService.getData();

    setState(() {
      temperatureDataList = newTemperatureDataList;
    });
  }

  @override
  void initState() {
    super.initState();
    makeGetTemperatureDataRequest();
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => makeGetTemperatureDataRequest(),
    );
  }

  _toStatisticsDataRecent(List<TemperatureData> hdList) {
    List<Map<dynamic, dynamic>> data = hdList.reversed.map((hd) => hd.toStatisticsData()).toList();
    int numberOfSamples = data.length;
    int minuteConstant = 10;
    int samples = 10 * minuteConstant;

    // TODO
    if (samples > numberOfSamples) {
      return data.reversed.toList();
    }

    List<Map<dynamic, dynamic>> filteredData = [];
    for (int i = numberOfSamples - 1; i > numberOfSamples - 1 - samples; i--) {
      filteredData.add(data[i]);
    }

    return filteredData.reversed.toList();
  }

  _toStatisticsDataDay(List<TemperatureData> hdList) {
    List<Map<dynamic, dynamic>> data = hdList.reversed.map((hd) => hd.toStatisticsData()).toList();
    int numberOfSamples = data.length;
    int minuteConstant = 10;
    int samples = 30 * minuteConstant;
    int segmente = 8;
    int samplesPerSegment = samples ~/ segmente;
    int startIndex = startTimeMinutes * minuteConstant;

    // TODO
    if (samples > numberOfSamples) {
      return data.reversed.toList();
    }

    List<Map<dynamic, dynamic>> filteredData = [];
    for (int i = 0; i < segmente; i++) {
      filteredData.add(data[startIndex + i * samplesPerSegment]);
    }

    return filteredData.toList();
  }

  _getMinValue(List<TemperatureData> hdList) {
    double min = hdList[0].celsius;

    for (int i = 1; i < hdList.length; i++) {
      if (hdList[i].celsius < min) {
        min = hdList[i].celsius;
      }
    }

    return min;
  }

  _getMaxValue(List<TemperatureData> hdList) {
    double max = hdList[0].celsius;

    for (int i = 1; i < hdList.length; i++) {
      if (hdList[i].celsius > max) {
        max = hdList[i].celsius;
      }
    }

    return max;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text("Temperatura aer"),
        ),
        body: RefreshIndicator(
          onRefresh: makeGetTemperatureDataRequest,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (temperatureDataList == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if ((temperatureDataList ?? []).isEmpty) {
      return const Center(
        child: Text("No elements"),
      );
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 16,
            ),
            if ((temperatureDataList ?? []).isNotEmpty) ...[
              Text(
                "Temperatura actuala ${temperatureDataList?.elementAt(0).celsius}°C",
                style: Theme.of(context).textTheme.headline5,
              ),
            ],
            const SizedBox(height: 32),
            Text(
              "Ultimele 10 minute:",
              style: Theme.of(context).textTheme.headline6,
            ),
            Divider(),
            SizedBox(
              height: 300,
              child: Chart(
                data: (temperatureDataList ?? []).isNotEmpty ? _toStatisticsDataRecent(temperatureDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'celsius': Variable(
                    accessor: (Map map) => (map['celsius'] as num),
                    scale: LinearScale(
                      min: _getMinValue(temperatureDataList!),
                      max: _getMaxValue(temperatureDataList!),
                      tickCount: 10,
                      formatter: (value) => "${value.round()}°C",
                    ),
                  ),
                },
                elements: [
                  LineElement(
                    color: ColorAttr(value: Colors.blue),
                    size: SizeAttr(value: 2),
                  ),
                  PointElement(
                    color: ColorAttr(value: Colors.red),
                    size: SizeAttr(value: 5),
                  ),
                ],
                axes: [
                  AxisGuide(
                    line: StrokeStyle(
                      color: Colors.blue,
                    ),
                    label: LabelStyle(
                      textAlign: TextAlign.center,
                      maxWidth: 40,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      offset: Offset(0, 12),
                    ),
                  ),
                  AxisGuide(
                    line: StrokeStyle(
                      color: Colors.blue,
                    ),
                    label: LabelStyle(
                      maxWidth: 40,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      offset: Offset(0, 0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Istoric",
              style: Theme.of(context).textTheme.headline6,
            ),
            Divider(),
            Slider(
              value: startTimeMinutes.roundToDouble(),
              min: 0,
              max: 120,
              onChanged: (double newTime) {
                setState(() {
                  startTimeMinutes = newTime.round();
                });
              },
            ),
            SizedBox(
              height: 300,
              child: Chart(
                data: (temperatureDataList ?? []).isNotEmpty ? _toStatisticsDataDay(temperatureDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'humidity': Variable(
                    accessor: (Map map) => (map['celsius'] as num),
                    scale: LinearScale(
                      min: _getMinValue(temperatureDataList!),
                      max: _getMaxValue(temperatureDataList!),
                      tickCount: 10,
                      formatter: (value) => "${value.round()}°C",
                    ),
                  ),
                },
                elements: [
                  LineElement(
                    color: ColorAttr(value: Colors.blue),
                    size: SizeAttr(value: 2),
                  ),
                  PointElement(
                    color: ColorAttr(value: Colors.red),
                    size: SizeAttr(value: 5),
                  ),
                ],
                axes: [
                  AxisGuide(
                    line: StrokeStyle(
                      color: Colors.blue,
                    ),
                    label: LabelStyle(
                      textAlign: TextAlign.center,
                      maxWidth: 40,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      offset: Offset(0, 12),
                    ),
                  ),
                  AxisGuide(
                    line: StrokeStyle(
                      color: Colors.blue,
                    ),
                    label: LabelStyle(
                      maxWidth: 40,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      offset: Offset(0, 0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 64),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }
}
