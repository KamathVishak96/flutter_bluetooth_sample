import 'dart:developer';

import 'package:bluetooth_sample/Models.dart';
import 'package:bluetooth_sample/TextWidget.dart';
import 'package:bluetooth_sample/scan_flow/BreastSizePage.dart';
import 'package:bluetooth_sample/scan_flow/BreastTypePage.dart';
import 'package:bluetooth_sample/scan_flow/ConfirmBreastTypePage.dart';
import 'package:bluetooth_sample/scan_flow/ConnectBtPage.dart';
import 'package:bluetooth_sample/scan_flow/ScanPage.dart';
import 'package:bluetooth_sample/scan_flow/ScanReportPage.dart';
import 'package:bluetooth_sample/scan_flow/StartScanPage.dart';
import 'package:bluetooth_sample/scan_flow/bloc/ScanStreamBloc.dart';
import 'package:bluetooth_sample/widgets/ControlledVisibility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ScanProcessMain extends StatefulWidget {
  static ScanProcessMainState? of(BuildContext context) {
    return context.findAncestorStateOfType<ScanProcessMainState>();
  }

  final String? scanPageRoute;

  ScanProcessMain({
    Key? key,
    this.scanPageRoute,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScanProcessMainState();
}

const routeConnectBt = "/connect";
const routeBreastType = "/breastType";
const routeConfirmBreastType = "/confirmBreastType";
const routeBreastSize = "/breastSize";
const routeStartScan = "/startScan";
const routeScan = "/scan";
const routeScanReport = "/scanReport";
const routeScanMain = "/scanMain";

class ScanProcessMainState extends State<ScanProcessMain> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  BluetoothConnection? connection;
  int itemsOnStack = 0;
  TextWidgetController textWidgetController =
      TextWidgetController(text: "Scan");
  VisibilityController saveScanController = VisibilityController(false);

  @override
  void dispose() {
    connection?.finish();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void onConnectionSuccess(String address) async {
    log("onConnectionSuccess called with: address: [$address]");
    connection = await BluetoothConnection.toAddress(address);
    var bloc = _navigatorKey.currentContext?.read<ScanStreamBloc>();
    if (bloc?.scanDetails == null) {
      bloc?.scanDetails = ScanDetails();
    }
    if (connection != null)
      _navigatorKey.currentContext
          ?.read<ScanStreamBloc>()
          .setConnection(connection!);
    _navigatorKey.currentState?.pushNamed(routeBreastType);
  }

  void onBreastTypeSelected() {
    log("onBreastTypeSelected called");
    _navigatorKey.currentState?.pushNamed(routeConfirmBreastType);
  }

  void onBreastTypeConfirmed() {
    log("onBreastTypeConfirmed called");
    _navigatorKey.currentState
        ?.pushNamed(routeBreastSize);
  }

  void onBreastSizeConfirmed() {
    log("onBreastSizeConfirmed called");
    _navigatorKey.currentState?.pushNamed(routeStartScan,);
  }

  void onStartScan(String breastSide) {
    log("onStartScan called with: breastSide: [],");
    _navigatorKey.currentState?.pushNamed(routeScan, arguments: {
      "breastSide": breastSide,
    });
  }

  void onEndScan() {
    log("onEndScan called");
    saveScanController.setVisibility(true);
    _navigatorKey.currentState?.pushNamed(routeScanReport);
  }

  Future<bool> _isExitDesired() async {
    return await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Are you sure?'),
                content:
                    const Text('If you exit, your scan progress will be lost.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Leave'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Stay'),
                  ),
                ],
              );
            }) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        log("Can pop: ${_navigatorKey.currentState?.canPop()}");
        if (itemsOnStack == 6 || itemsOnStack == 7) {
          return _isExitDesired();
        } else {
          itemsOnStack--;
          _navigatorKey.currentState?.maybePop();
        }
        return itemsOnStack == 0;
      },
      child: Scaffold(
          appBar: AppBar(
            title: TextWidget(textWidgetController),
            actions: [
              ControlledVisibility(
                  saveScanController,
                  InkWell(
                    child: Icon(Icons.exit_to_app),
                    onTap: () {
                      onEndScan();
                    },
                  ))
            ],
          ),
          body: BlocProvider(
            create: (context) => ScanStreamBloc(InitState()),
            child: Navigator(
              key: _navigatorKey,
              initialRoute: routeConnectBt,
              onGenerateRoute: _onGenerateRoute,
              observers: [],
            ),
          )),
    );
  }

  Route _onGenerateRoute(RouteSettings settings) {
    Widget? page;
    log("_onGenerateRoute called with [${settings.name}]");
    var args = settings.arguments as Map?;
    switch (settings.name) {
      case routeConnectBt:
        page = ConnectBtPage(
          onDeviceSelected: (String address) {
            onConnectionSuccess(address);
          },
        );
        itemsOnStack++;
        textWidgetController.setText("Connect");
        break;
      case routeBreastType:
        page = BreastTypePage(
          onBreastTypeSelected: () {
            onBreastTypeSelected();
          },
        );
        itemsOnStack++;
        textWidgetController.setText("Breast Type");
        break;
      case routeConfirmBreastType:
        page = ConfirmBreastTypePage(
          onBreastTypeConfirmed: () {
            onBreastTypeConfirmed();
          },
        );
        itemsOnStack++;
        textWidgetController.setText("Confirm Breast Type");
        break;
      case routeBreastSize:
        page = BreastSizePage(
          onBreastSizeSet: () {
            onBreastSizeConfirmed();
          },
        );
        itemsOnStack++;
        textWidgetController.setText("Breast Size");
        break;
      case routeStartScan:
        page = StartScanPage(
          onStartScan: (breastSide) {
            onStartScan(breastSide);
          },
        );
        itemsOnStack++;
        textWidgetController.setText("Start Scan");
        break;
      case routeScan:
        page = ScanPage(
          onScanComplete: (breastSide, breastType, ub, lb) {},
          breastSide: args?["breastSide"] ?? "",
        );
        itemsOnStack++;
        textWidgetController.setText("Scan");
        saveScanController.setVisibility(true);
        break;
      case routeScanReport:
        page = ScanReportPage();
        itemsOnStack++;
        textWidgetController.setText("Scan Report");
        break;
    }
    return _createRoute(page);
  }

  Route _createRoute(Widget? page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          page ?? Container(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
