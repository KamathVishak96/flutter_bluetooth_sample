import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bluetooth_sample/Models.dart';
import 'package:bluetooth_sample/SolidCircleProgressIndicatorWidget.dart';
import 'package:bluetooth_sample/TextWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:location/location.dart';

class CommandsPage extends StatefulWidget {
  String connectedDevice;
  String address;

  CommandsPage(this.connectedDevice, this.address);

  @override
  State<StatefulWidget> createState() => CommandsPageState();
}

class CommandsPageState extends State<CommandsPage> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  String data = "";
  TextWidgetController controller = TextWidgetController();
  IndicatorRadiusController indicatorController = IndicatorRadiusController();
  BluetoothConnection? connection;
  StreamSubscription? subscription;
  String? command;
  String prevCommand = "";

  @override
  void dispose() {
    if(command == "^") {
      sendCommand("^");
    }
    connection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.connectedDevice),
        ),
        body: FutureBuilder(
          future: BluetoothConnection.toAddress(widget.address),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (connection == null) {
                connection = (snapshot.data as BluetoothConnection);
                if (subscription == null) {
                  subscription = connection?.input?.listen((Uint8List data) {
                    //print('Data incoming: $data');
                    print('Length: ${data.length}');
                    print('Command: $command');
                    if (command == "^") {
                      ScanDataResponse? scanData = ScanDataResponse.parse(data.join(","));
                      controller.setText(scanData.toString());
                      indicatorController.setRadius(scanData?.pressure.toDouble() ?? 0.0);
                    } else if (command == "#") {
                      controller.setText(
                          BatteryResponse.parse(String.fromCharCodes(data))?.toString() ??
                              "");
                    } else if (command == "_") {
                      controller.setText(
                          SensorSerialNumberResponse.parse(String.fromCharCodes(data))
                              ?.toString() ??
                              "");
                    } else if (command == "!") {
                      controller.setText(
                          VersionResponse.parse(String.fromCharCodes(data))?.toString() ??
                              "");
                    } else {
                      //controller.setText(data.toString());
                    }
                    if(prevCommand == "^")
                      command = "^";
                  });
                }
              }
              return Column(
                children: [
                  TextWidget(controller),
                  ListView(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: [
                      InkWell(
                        child: ListTile(
                          title: Text("Version"),
                          leading: Icon(Icons.looks_one),
                        ),
                        onTap: () async {
                          sendCommand("!");
                        },
                      ),
                      InkWell(
                        child: ListTile(
                            title: Text("Battery"),
                            leading: Icon(Icons.battery_charging_full_sharp)),
                        onTap: () {
                          sendCommand("#");
                        },
                      ),
                      InkWell(
                        child: ListTile(
                            title: Text("Serial Number"),
                            leading: Icon(Icons.tag)),
                        onTap: () {
                          sendCommand("_");
                        },
                      ),
                      InkWell(
                        child: ListTile(
                            title: Text("Toggle Scan"),
                            leading: Icon(Icons.scanner)),
                        onTap: () {
                          sendCommand("^");
                        },
                      ),
                      InkWell(
                        child: ListTile(
                            title: Text("Calibrate"),
                            leading: Icon(Icons.compass_calibration)),
                        onTap: () {
                          sendCommand("&");
                        },
                      ),
                      InkWell(
                        child: ListTile(
                            title: Text("Location"),
                            leading: Icon(Icons.location_on)),
                        onTap: () {
                          fetchLocation();
                        },
                      ),
                    ],
                  ),
                  SolidCircleProgressIndicatorWidget(indicatorController),
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          },
        ));
  }

  void sendCommand(String source) {
    List<int> list = utf8.encode(source);
    if(command == "^" && source != "^") {
      prevCommand = "^";
    }
    command = source;
    Uint8List bytes = Uint8List.fromList(list);
    connection?.output.add(bytes);
  }

  void fetchLocation() async {
    Location location = new Location();
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    print(_locationData);
    controller.setText(
        "Latitude: ${_locationData.latitude}, Longitude: ${_locationData.longitude}");
  }
}
