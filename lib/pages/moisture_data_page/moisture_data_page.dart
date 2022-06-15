import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/models/moisture_data.dart';
import 'package:mobile_client/pages/moisture_data_page/moisture_data_card.dart';
import 'package:mobile_client/services/moisture_data_service.dart';

import '../../app_drawer.dart';

class MoistureDataPage extends StatefulWidget {
  const MoistureDataPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MoistureDataPageState();
  }
}

class _MoistureDataPageState extends State<MoistureDataPage> {
  Timer? timer;
  MoistureData? moistureData;
  List<MoistureData>? moistureDataList;
  int startTimeMinutes = 0;

  Future<void> makeGetMoistureDataRequest() async {
    List<MoistureData> newMoistureDataList = await MoistureDataService.getData();

    setState(() {
      moistureDataList = newMoistureDataList;
    });
  }

  _toStatisticsDataRecent(List<MoistureData> hdList) {
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

  _toStatisticsDataDay(List<MoistureData> hdList) {
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

  _getMinValue(List<MoistureData> hdList) {
    double min = hdList[0].moisture;

    for (int i = 1; i < hdList.length; i++) {
      if (hdList[i].moisture < min) {
        min = hdList[i].moisture;
      }
    }

    return min;
  }

  _getMaxValue(List<MoistureData> hdList) {
    double max = hdList[0].moisture;

    for (int i = 1; i < hdList.length; i++) {
      if (hdList[i].moisture > max) {
        max = hdList[i].moisture;
      }
    }

    return max;
  }

  @override
  void initState() {
    super.initState();
    makeGetMoistureDataRequest();
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => makeGetMoistureDataRequest(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text("Umiditate sol"),
        ),
        body: RefreshIndicator(
          onRefresh: makeGetMoistureDataRequest,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (moistureDataList == null) {
      return const Center(
        child: CircularProgressIndicator(),
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
            if ((moistureDataList ?? []).isNotEmpty) ...[
              Text(
                "Umiditatea actuala ${moistureDataList?.elementAt(0).moisture.round()}\n(${getMoistureName(moistureDataList?.elementAt(0).moisture ?? 1024)})",
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
                data: (moistureDataList ?? []).isNotEmpty ? _toStatisticsDataRecent(moistureDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'moisture': Variable(
                    accessor: (Map map) => (map['moisture'] as num),
                    scale: LinearScale(
                      min: _getMinValue(moistureDataList!),
                      max: _getMaxValue(moistureDataList!),
                      tickCount: 5,
                      formatter: (value) => "${value.round()}",
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
                data: (moistureDataList ?? []).isNotEmpty ? _toStatisticsDataDay(moistureDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'humidity': Variable(
                    accessor: (Map map) => (map['moisture'] as num),
                    scale: LinearScale(
                      min: _getMinValue(moistureDataList!),
                      max: _getMaxValue(moistureDataList!),
                      tickCount: 10,
                      formatter: (value) => "${value.round()}",
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

  String getMoistureName(double moisture) {
    if (moisture < 700) {
      return "Foarte umed";
    }

    if (moisture < 800) {
      return "Umed";
    }

    if (moisture < 900) {
      return "Uscat";
    }

    return "Foarte uscat";
  }
}
