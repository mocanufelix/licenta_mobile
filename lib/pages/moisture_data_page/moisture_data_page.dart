import 'dart:async';
import 'package:flutter/material.dart';
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

  Future<void> makeGetMoistureDataRequest() async {
    List<MoistureData> newMoistureDataList =
        await MoistureDataService.getData();

    setState(() {
      moistureDataList = newMoistureDataList;
    });
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
        appBar: AppBar(),
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

    return ListView.builder(
      itemCount: moistureDataList!.length,
      itemBuilder: (context, index) {
        return MoistureDataCard(
          data: moistureDataList![index],
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
