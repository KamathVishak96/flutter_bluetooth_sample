import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:bluetooth_sample/Models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:location/location.dart';

enum BlocEvents {
  START_SCAN,
  STOP_SCAN,
  GET_VERSION_NUMBER,
  GET_BATTERY,
  GET_SENSOR_SERIAL_NUMBER,
  GET_USER_LOCATION
}

abstract class ScanStreamState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitState extends ScanStreamState {}

class CommandSentState extends ScanStreamState {
  String command;
  /*
  String? cmdMsg;
    get  async => command == ScanDataResponse.cmdVersionNumber ? "Fetching Version Number" : command == ScanDataResponse.cmdSensorSerialNumber ? "Fetching Sensor Serial Number" : command == ScanDataResponse.cmdBattery ? "Fetching Battery percent" : "";
*/
  CommandSentState(this.command);
}

class FetchLocationState extends ScanStreamState {}

class LocationReceivedState extends ScanStreamState {
  double lat;
  double lng;

  LocationReceivedState(this.lat, this.lng);
}

class StreamReceivedState extends ScanStreamState {
  StreamReceivedState(Stream<Uint8List> stream);
}

class ResponseReceivedState extends ScanStreamState {
  Response? response;
  String command;

  ResponseReceivedState(this.command, this.response);
}

class ScanStreamBloc extends Bloc<BlocEvents, ScanStreamState> {
  BluetoothConnection? connection;
  ScanDetails? scanDetails;
  bool isStoppedEvents = false;

  ScanStreamBloc(ScanStreamState initialState) : super(initialState);

  final StreamController<Uint8List> streamController =
      StreamController<Uint8List>.broadcast();

  setConnection(BluetoothConnection connection) {
    var connTime = DateTime.now().millisecondsSinceEpoch;
    this.connection = connection;
    this.connection?.input?.listen((Uint8List event) {
      var eventTime = DateTime.now().millisecondsSinceEpoch;
      log("EventTime: $eventTime, ConnTime: $connTime");
      if(!isStoppedEvents && (eventTime - connTime) <= 2000) {
        isStoppedEvents = true;
        sendCommand("^");
      }
      log("Event: $event");
      streamController.sink.add(event);
    });
  }

  closeSink() {
    streamController.sink.close();
  }

  @override
  Stream<ScanStreamState> mapEventToState(BlocEvents event) async* {
    switch (event) {
      case BlocEvents.START_SCAN:
        yield CommandSentState(ScanDataResponse.cmdToggleScan);
        sendCommand(ScanDataResponse.cmdToggleScan);
        yield StreamReceivedState(streamController.stream);
        break;
      case BlocEvents.STOP_SCAN:
        sendCommand(ScanDataResponse.cmdToggleScan);
        break;
      case BlocEvents.GET_VERSION_NUMBER:
        yield CommandSentState(ScanDataResponse.cmdVersionNumber);
        sendCommand(ScanDataResponse.cmdVersionNumber);
        VersionResponse? response = VersionResponse.parse(
            String.fromCharCodes((await streamController.stream.first)));
        yield ResponseReceivedState(ScanDataResponse.cmdVersionNumber, response);
        break;
      case BlocEvents.GET_SENSOR_SERIAL_NUMBER:
        yield CommandSentState(ScanDataResponse.cmdSensorSerialNumber);
        sendCommand(ScanDataResponse.cmdSensorSerialNumber);
        SensorSerialNumberResponse? response = SensorSerialNumberResponse.parse(
            String.fromCharCodes((await streamController.stream.first)));
        yield ResponseReceivedState(ScanDataResponse.cmdSensorSerialNumber, response);
        break;
      case BlocEvents.GET_USER_LOCATION:
        yield FetchLocationState();
        var location = await fetchLocation();
        if (location != null)
          yield LocationReceivedState(location.latitude ?? 0.0, location.longitude ?? 0.0);
        break;
      case BlocEvents.GET_BATTERY:
        yield CommandSentState(ScanDataResponse.cmdBattery);
        sendCommand(ScanDataResponse.cmdBattery);
        BatteryResponse? response = BatteryResponse.parse(
            String.fromCharCodes((await streamController.stream.first)));
        yield ResponseReceivedState(ScanDataResponse.cmdBattery, response);
        break;
    }
  }

  Future<LocationData?> fetchLocation() async {
    Location location = new Location();
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }

    _locationData = await location.getLocation();
    return _locationData;
  }

  sendCommand(String source) async {
    log("Command sent: $source");
    List<int> list = utf8.encode(source);
    Uint8List bytes = Uint8List.fromList(list);
    connection?.output.add(bytes);
  }
}
