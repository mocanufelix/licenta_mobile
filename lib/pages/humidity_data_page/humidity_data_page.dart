import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Future<void> makeGetHumidityDataRequest() async {
    List<HumidityData> newHumidityDataList =
        await HumidityDataService.getData();

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
        appBar: AppBar(),
        body: RefreshIndicator(
          onRefresh: makeGetHumidityDataRequest,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (humidityDataList == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      itemCount: humidityDataList!.length,
      itemBuilder: (context, index) {
        return HumidityDataCard(
          data: humidityDataList![index],
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
