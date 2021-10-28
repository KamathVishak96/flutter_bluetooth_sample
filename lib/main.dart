import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bluetooth_sample/CommandsPage.dart';
import 'package:bluetooth_sample/scan_flow/ConnectBtPage.dart';
import 'package:bluetooth_sample/scan_flow/ScanPage.dart';
import 'package:bluetooth_sample/scan_flow/ScanPage.dart';
import 'package:bluetooth_sample/ScanProcessMain.dart';
import 'package:bluetooth_sample/SolidCircleProgressIndicatorWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: (settings) {
        Widget page;
        if (settings.name?.contains("/") == true) {
          final subRoute = settings.name;
          page = ScanProcessMain(
            scanPageRoute: subRoute,
          );
        } else {
          throw Exception('Unknown route: ${settings.name}');
        }
        return MaterialPageRoute<dynamic>(
          builder: (context) {
            return page;
          },
          settings: settings,
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> devices = List.empty(growable: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, routeConnectBt);
              },
              child: Text("Scan")),
          ListView.builder(
            shrinkWrap: true,
            itemBuilder: (context, index) {
              BluetoothDevice device = devices[index];
              return InkWell(
                onTap: () async {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CommandsPage(device.name ?? "", device.address),
                  ));
                },
                child: ListTile(
                    title: Column(children: [
                  Text(
                    device.name ?? "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  Text(device.address)
                ])),
              );
            },
            itemCount: devices.length,
          ),
        ],
      ),
      floatingActionButton: Column(
        children: [
          FloatingActionButton(
            onPressed: searchForBluetoothDevice,
            tooltip: 'Scan',
            child: Icon(Icons.play_arrow_rounded),
          ),
        ],
        mainAxisSize: MainAxisSize.min,
      ),
    );
  }

  void searchForBluetoothDevice() {
    print("Starting Scan");
    bluetoothSerial.startDiscovery().listen((result) {
      if (!devices.any((element) => element.address == result.device.address))
        setState(() {
          devices.add(result.device);
        });
    });
  }
}
