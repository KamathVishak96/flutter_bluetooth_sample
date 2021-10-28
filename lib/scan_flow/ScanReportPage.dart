import 'package:bluetooth_sample/Models.dart';
import 'package:bluetooth_sample/scan_flow/bloc/ScanStreamBloc.dart';
import 'package:bluetooth_sample/widgets/BreastGridsWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScanReportPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScanReportPageState();
}

class ScanReportPageState extends State<ScanReportPage> {
  ScanDetails? scanDetails;

  @override
  void initState() {
    scanDetails = context.read<ScanStreamBloc>().scanDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text("Breast Type: ${scanDetails?.breastType}"),
        Text("Upper Bust: ${scanDetails?.overBust}"),
        Text("Lower Bust: ${scanDetails?.underBust}"),
        Text("deviceSerialNumber: ${scanDetails?.deviceSerialNumber}"),
        Text("sensorSerialNumber: ${scanDetails?.sensorSerialNumber}"),
        Text("battery: ${scanDetails?.battery}"),
        Text("hardwareVersion: ${scanDetails?.hardwareVersion}"),
        Text("Location: ${scanDetails?.lat} Lat, ${scanDetails?.lng} Lng"),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
                padding: EdgeInsets.only(
                    left: 16.0, right: 8.0, top: 16.0, bottom: 16.0),
                child: BreastGridsWidget(
                  controller: BreastGridsWidgetController(
                      scanDetails?.rightBreastData
                              ?.map((e) => ScanTile(
                                  scanDetails?.rightBreastData?.indexWhere(
                                          (element) => element == e) ??
                                      -1,
                                  e))
                              .toList() ??
                          [],
                      "Right"),
                  breastSide: "Right",
                  grids: scanDetails?.rightBreastData
                          ?.map((e) => ScanTile(
                              scanDetails?.rightBreastData
                                      ?.indexWhere((element) => element == e) ??
                                  -1,
                              e))
                          .toList() ??
                      [],
                  onItemClicked: (pos) {},
                  boxSize: size.width.toInt() ~/ 14,
                )),
            Padding(
                padding: EdgeInsets.only(
                    left: 8.0, right: 16.0, top: 16.0, bottom: 16.0),
                child: BreastGridsWidget(
                  controller: BreastGridsWidgetController(
                      scanDetails?.leftBreastData
                              ?.map((e) => ScanTile(
                                  scanDetails?.leftBreastData?.indexWhere(
                                          (element) => element == e) ??
                                      -1,
                                  e))
                              .toList() ??
                          [],
                      "Left"),
                  breastSide: "Left",
                  grids: scanDetails?.leftBreastData
                          ?.map((e) => ScanTile(
                              scanDetails?.leftBreastData
                                      ?.indexWhere((element) => element == e) ??
                                  -1,
                              e))
                          .toList() ??
                      [],
                  onItemClicked: (pos) {},
                  boxSize: size.width.toInt() ~/ 14,
                )),
          ],
        )
      ],
    );
  }
}
