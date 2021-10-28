import 'dart:developer';

import 'package:bluetooth_sample/scan_flow/bloc/ScanStreamBloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../Models.dart';

class ConnectBtPage extends StatefulWidget {
  final void Function(String address) onDeviceSelected;

  const ConnectBtPage({Key? key, required this.onDeviceSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConnectBtPageState();
}

class ConnectBtPageState extends State<ConnectBtPage> {
  FlutterBluetoothSerial bluetoothSerial = FlutterBluetoothSerial.instance;
  List<BluetoothDevice> devices = List.empty(growable: true);

  @override
  void initState() {
    if(context.read<ScanStreamBloc>().scanDetails == null)
      context.read<ScanStreamBloc>().scanDetails = ScanDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("Building ConnectBTPage");

    return Column(
      children: [
        InkWell(
          child: SizedBox(
            width: 100,
            height: 100,
            child: Icon(
              Icons.bluetooth_searching,
            ),
          ),
          onTap: () {
            searchForBluetoothDevice();
          },
        ),
        ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            BluetoothDevice device = devices[index];
            return InkWell(
              onTap: () async {
                widget.onDeviceSelected(device.address);
              },
              child: ListTile(
                leading: Icon(Icons.bluetooth),
                title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name ?? "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      Text(device.address)
                    ]),
                trailing: Icon(Icons.check_circle),
              ),
            );
          },
          itemCount: devices.length,
        ),
      ],
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
