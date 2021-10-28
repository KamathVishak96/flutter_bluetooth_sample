import 'dart:developer';
import 'package:bluetooth_sample/Models.dart';
import 'package:bluetooth_sample/scan_flow/bloc/ScanStreamBloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartScanPage extends StatefulWidget {
  final void Function(String breastSide) onStartScan;

  StartScanPage({
    Key? key,
    required this.onStartScan,
  });

  @override
  State<StatefulWidget> createState() => StartScanPageState();
}

class StartScanPageState extends State<StartScanPage> {
  ScanStreamBloc? bloc;
  ScanDetails? scanDetails;

  @override
  void initState() {
    bloc = context.read<ScanStreamBloc>();
    bloc?.add(BlocEvents.GET_VERSION_NUMBER);
    scanDetails = bloc?.scanDetails;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanStreamBloc, ScanStreamState>(
      builder: (_, state) {
        log(state.toString());
        var loadingMessage = "";
        if (state is CommandSentState /* || state is FetchLocationState*/) {
          var command = state.command;
          loadingMessage = command == ScanDataResponse.cmdVersionNumber
              ? "Fetching Version Number"
              : command == ScanDataResponse.cmdSensorSerialNumber
                  ? "Fetching Sensor Serial Number"
                  : command == ScanDataResponse.cmdBattery
                      ? "Fetching Battery percent"
                      : "";
        } else if (state is FetchLocationState) {
          loadingMessage = "Fetching device Location";
        } else if (state is ResponseReceivedState) {
          if (state.command == ScanDataResponse.cmdVersionNumber) {
            bloc?.scanDetails?.hardwareVersion =
                (state.response as VersionResponse?)?.versionNumber;
            bloc?.scanDetails?.deviceSerialNumber =
                (state.response as VersionResponse?)?.serialNumber;
            bloc?.add(BlocEvents.GET_SENSOR_SERIAL_NUMBER);
          } else if (state.command == ScanDataResponse.cmdSensorSerialNumber) {
            bloc?.scanDetails?.sensorSerialNumber =
                (state.response as SensorSerialNumberResponse?)?.slNo;
            bloc?.add(BlocEvents.GET_BATTERY);
          } else if (state.command == ScanDataResponse.cmdBattery) {
            bloc?.scanDetails?.battery =
                (state.response as BatteryResponse?)?.percent;
            bloc?.add(BlocEvents.GET_USER_LOCATION);
          }
        } else if (state is LocationReceivedState) {
          bloc?.scanDetails?.lat = state.lat;
          bloc?.scanDetails?.lng = state.lng;
          return startScanWidget(false, "");
        }
        return startScanWidget(true, loadingMessage);
      },
    );
  }

  Widget startScanWidget(bool isLoading, String loadingState) {
    return Stack(children: [
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Breast Type: ${scanDetails?.breastType}"),
            Text("Upper Bust: ${scanDetails?.overBust}"),
            Text("Lower Bust: ${scanDetails?.underBust}"),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(isLoading
                  ? loadingState
                  : "Which breast do you want to scan first?"),
            ),
            isLoading ? CircularProgressIndicator() : Container(),
          ],
        ),
      ),
      Positioned(
          bottom: 16,
          left: 16,
          child: MaterialButton(
            child: Text("Left"),
            onPressed: isLoading
                ? null
                : () {
                    widget.onStartScan("Left");
                  },
          )),
      Positioned(
          bottom: 16,
          right: 16,
          child: MaterialButton(
            child: Text("Right"),
            onPressed: isLoading
                ? null
                : () {
                    widget.onStartScan("Right");
                  },
          )),
    ]);
  }
}
