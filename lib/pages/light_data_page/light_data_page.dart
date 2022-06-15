import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/models/light_data.dart';
import 'package:mobile_client/pages/light_data_page/light_data_card.dart';
import 'package:mobile_client/services/light_data_service.dart';

import '../../app_drawer.dart';

class LightDataPage extends StatefulWidget {
  const LightDataPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _LightDataPageState();
  }
}

class _LightDataPageState extends State<LightDataPage> {
  Timer? timer;
  LightData? lightData;
  List<LightData>? lightDataList;
  int startTimeMinutes = 0;

  _toStatisticsDataRecent(List<LightData> hdList) {
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

  _toStatisticsDataDay(List<LightData> hdList) {
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

  _getMinValue(List<LightData> hdList) {
    double min = hdList[0].light;

    for (int i = 1; i < hdList.length; i++) {
      if (hdList[i].light < min) {
        min = hdList[i].light;
      }
    }

    return min;
  }

  _getMaxValue(List<LightData> hdList) {
    double max = hdList[0].light;

    for (int i = 1; i < hdList.length; i++) {
      if (hdList[i].light > max) {
        max = hdList[i].light;
      }
    }

    return max;
  }

  Future<void> makeGetLightDataRequest() async {
    List<LightData> newLightDataList = await LightDataService.getData();

    setState(() {
      lightDataList = newLightDataList;
    });
  }

  @override
  void initState() {
    super.initState();
    makeGetLightDataRequest();
    timer = Timer.periodic(
      const Duration(seconds: 6),
      (timer) => makeGetLightDataRequest(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text("Luminozitate"),
        ),
        body: RefreshIndicator(
          onRefresh: makeGetLightDataRequest,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (lightDataList == null) {
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
            if ((lightDataList ?? []).isNotEmpty) ...[
              Text(
                "Luminozitatea actuala ${lightDataList?.elementAt(0).light.round()}",
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
                data: (lightDataList ?? []).isNotEmpty ? _toStatisticsDataRecent(lightDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'light': Variable(
                    accessor: (Map map) => (map['light'] as num),
                    scale: LinearScale(
                      min: _getMinValue(lightDataList!),
                      max: _getMaxValue(lightDataList!),
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
                data: (lightDataList ?? []).isNotEmpty ? _toStatisticsDataDay(lightDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'humidity': Variable(
                    accessor: (Map map) => (map['light'] as num),
                    scale: LinearScale(
                      min: _getMinValue(lightDataList!),
                      max: _getMaxValue(lightDataList!),
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
}
