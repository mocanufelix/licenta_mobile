import 'dart:async';
import 'package:flutter/material.dart';
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
        appBar: AppBar(),
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

    return ListView.builder(
      itemCount: lightDataList!.length,
      itemBuilder: (context, index) {
        return LightDataCard(
          data: lightDataList![index],
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
