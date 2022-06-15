import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client/models/humidity_data.dart';
import 'package:mobile_client/pages/humidity_data_page/humidity_data_card.dart';
import 'package:mobile_client/services/humidity_data_service.dart';
import '../../app_drawer.dart';

class HumidityDataPage extends StatefulWidget {
  const HumidityDataPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HumidityDataPageState();
  }
}

class _HumidityDataPageState extends State<HumidityDataPage> {
  Timer? timer;
  HumidityData? humidityData;
  List<HumidityData>? humidityDataList;
  int startTimeMinutes = 0;

  Future<void> makeGetHumidityDataRequest() async {
    List<HumidityData> newHumidityDataList = await HumidityDataService.getData();

    setState(() {
      humidityDataList = newHumidityDataList;
    });
  }

  @override
  void initState() {
    super.initState();
    makeGetHumidityDataRequest();
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) => makeGetHumidityDataRequest(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text("Umiditate aer"),
        ),
        body: RefreshIndicator(
          onRefresh: makeGetHumidityDataRequest,
          child: _buildBody(),
        ),
      ),
    );
  }

  _toStatisticsDataRecent(List<HumidityData> hdList) {
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

  _toStatisticsDataDay(List<HumidityData> hdList) {
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

  Widget _buildBody() {
    if (humidityDataList == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if ((humidityDataList ?? []).isEmpty) {
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
            if ((humidityDataList ?? []).isNotEmpty) ...[
              Text(
                "Umiditate actuala ${humidityDataList?.elementAt(0).humidity} %",
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
                data: (humidityDataList ?? []).isNotEmpty ? _toStatisticsDataRecent(humidityDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'humidity': Variable(
                    accessor: (Map map) => (map['humidity'] as num),
                    scale: LinearScale(
                      min: 0,
                      max: 100,
                      tickCount: 10,
                      formatter: (value) => "${value.round()} %",
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
              "Istoric umiditate",
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
                data: (humidityDataList ?? []).isNotEmpty ? _toStatisticsDataDay(humidityDataList!) : [],
                variables: {
                  'time': Variable(
                    accessor: (Map map) => (map['time'] as DateTime).toLocal(),
                    scale: TimeScale(
                      tickCount: 5,
                      formatter: (value) => DateFormat("kk:mm").format(value),
                    ),
                  ),
                  'humidity': Variable(
                    accessor: (Map map) => (map['humidity'] as num),
                    scale: LinearScale(
                      min: 0,
                      max: 100,
                      tickCount: 10,
                      formatter: (value) => "${value.round()} %",
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
