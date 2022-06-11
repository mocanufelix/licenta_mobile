import 'dart:async';
import 'package:flutter/material.dart';
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

  Future<void> makeGetTemperatureDataRequest() async {
    List<TemperatureData> newTemperatureDataList =
        await TemperatureDataService.getData();

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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(),
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

    return ListView.builder(
      itemCount: temperatureDataList!.length,
      itemBuilder: (context, index) {
        return TemperatureDataCard(
          data: temperatureDataList![index],
        );
      },
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
