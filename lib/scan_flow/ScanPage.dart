import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:bluetooth_sample/Models.dart';
import 'package:bluetooth_sample/TextWidget.dart';
import 'package:bluetooth_sample/scan_flow/bloc/ScanStreamBloc.dart';
import 'package:bluetooth_sample/widgets/BreastGridsWidget.dart';
import 'package:bluetooth_sample/widgets/SegmentedControl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../SolidCircleProgressIndicatorWidget.dart';

class ScanPage extends StatefulWidget {
  final void Function(String breast, String breastType, int ub, int lb)
      onScanComplete;
  final String breastSide;
  final BluetoothConnection? connection;

  const ScanPage(
      {Key? key,
      required this.onScanComplete,
      required this.breastSide,
      required this.connection})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ScanPageState();
}

class ScanPageState extends State<ScanPage> {
  BreastGridsWidgetController? gridsController;
  IndicatorRadiusController indicatorController = IndicatorRadiusController();
  StreamSubscription? subscription;
  BluetoothConnection? connection;
  Timer? timer;

  List<ScanTile> lBreastTiles =
      List.generate(30, (index) => ScanTile(index + 1, null));
  List<ScanTile> rBreastTiles =
      List.generate(30, (index) => ScanTile(index + 1, null));

  @override
  void initState() {
    log("initState() called");
    gridsController = BreastGridsWidgetController(
        widget.breastSide == "Left" ? lBreastTiles : rBreastTiles,
        widget.breastSide);

    connection = widget.connection;

    super.initState();
  }

  @override
  void dispose() {
    log("dispose() called");
    sendCommand("^");
    if (subscription != null) subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    startScan(context);
    return BlocBuilder<ScanStreamBloc, ScanStreamState>(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 64,
            width: 160,
            child: SegmentedControl(
              segmentedControlValue: widget.breastSide == "Left" ? 0 : 1,
              onValueChanged: (side) {
                if (side == "Right") {
                  gridsController?.setBreastSide("Right");
                  gridsController?.setGrids(rBreastTiles);
                } else if (side == "Left") {
                  gridsController?.setBreastSide("Left");
                  gridsController?.setGrids(lBreastTiles);
                }
              },
            ),
          ),
          Container(
            color: Colors.grey,
            child: BreastGridsWidget(
              controller: gridsController,
              breastSide: widget.breastSide,
              grids: widget.breastSide == "Left" ? lBreastTiles : rBreastTiles,
              onItemClicked: (pos) {
                gridsController?.setSelectedPosition(pos);
              },
            ),
          ),
          SolidCircleProgressIndicatorWidget(indicatorController),
        ],
      );
    },);
  }

  startScan(BuildContext context) async {
    await Future.delayed(Duration(seconds: 1));
    context.read<ScanStreamBloc>().streamController.stream.listen((data) {
      ScanDataResponse? scanData = ScanDataResponse.parse(data.join(","));
      log("Scan Data: $scanData");
      if (scanData != null && scanData.isOnTissue) {
        indicatorController.setVisibility(
            gridsController?.selectedPosition != null &&
                gridsController?.selectedPosition != -1);
        indicatorController.setRadius(scanData.pressure.toDouble());
        if (scanData.isPressureIdeal()) {
        } else {
          restartIdealTimer(scanData);
        }
      } else {
        indicatorController.setVisibility(false);
        indicatorController.setRadius(0.0);
      }
    });
    context.read<ScanStreamBloc>().add(BlocEvents.START_SCAN);
  }

  void sendCommand(String source) {
    List<int> list = utf8.encode(source);
    /*if(command == "^" && source != "^") {
      prevCommand = "^";
    }
    command = source;*/
    Uint8List bytes = Uint8List.fromList(list);
    connection?.output.add(bytes);
  }

  restartIdealTimer(ScanDataResponse scanData) async {
    if (timer != null) {
      log("Cancelling Timer");
      timer?.cancel();
      log("Cancelled Timer");
    }
    log("restartIdealTimer() called: ${scanData}");
    if (gridsController?.selectedPosition != null &&
        gridsController?.selectedPosition != -1)
      timer = Timer(Duration(seconds: 3), () {
        log("Timer Lambda Executing...");
        if (gridsController?.breastSide == "Left") {
          lBreastTiles[gridsController!.selectedPosition].data = scanData;
          gridsController?.setGrids(lBreastTiles);
          gridsController?.setSelectedPosition(-1);
          indicatorController.setVisibility(false);
          context.read<ScanStreamBloc>().scanDetails?.leftBreastData = lBreastTiles.map((e) => e.data).toList();
        } else if (gridsController?.breastSide == "Right") {
          rBreastTiles[gridsController!.selectedPosition].data = scanData;
          gridsController?.setGrids(rBreastTiles);
          gridsController?.setSelectedPosition(-1);
          indicatorController.setVisibility(false);
          context.read<ScanStreamBloc>().scanDetails?.rightBreastData = rBreastTiles.map((e) => e.data).toList();
        }
      });
  }
}
