class ScanTile {
  int pos;
  ScanDataResponse? data;
  ScanTile(this.pos, this.data);
}

class ScanDetails {
  String? date;
  List<ScanDataResponse?>? leftBreastData;
  List<ScanDataResponse?>? rightBreastData;
  String? deviceSerialNumber;
  String? sensorSerialNumber;
  double? battery;
  String? hardwareVersion;
  String? softwareVersion;
  double? lat;
  double? lng;
  double? underBust;
  double? overBust;
  String? breastType;

}

class ScanDataResponse {
  List<String> data;
  List<List<int>> dataIn2D;
  bool isOnTissue;
  bool isAirCalNeeded;
  int pressure;
  int batteryPercent;
  bool isSensorHung;
  bool isAbnormal;

  bool isPressureIdeal() => pressure >= 45 && pressure <= 70;

  ScanDataResponse(
    this.data,
    this.dataIn2D,
    this.isOnTissue,
    this.isAirCalNeeded,
    this.pressure,
    this.isAbnormal,
    this.batteryPercent,
    this.isSensorHung,
  );

  @override
  String toString() {
    return "Pressure: [$pressure],\t\tisOnTissue: [$isOnTissue],\nisAbnormal: [$isAbnormal],\t\tbatteryPercent: [$batteryPercent],";
  }

  static bool isValid(String? rawData) {
    return (rawData?.startsWith("254") == true && rawData?.endsWith("253") == true) == true;
  }

  static ScanDataResponse? parse(String rawData) {
    //print("parse() called with: rawData = [$rawData]");

    if (rawData == null || !(rawData.startsWith("254") && rawData.endsWith("253"))) return null;

    List<String> split = rawData.replaceAll(" ", "").split(",");
    List<String> data =
        split.sublist(1, split.length - 1); // removes the `fe` and `fd`
    //print("parse(): data = [$data]");

    // split into list of 10 elements each and convert to int from hex
    List<List<int>> dataIn2D = List.empty(growable: true);

    for (int i = 0; i < 8; i++) {
      List<int> row = List.empty(growable: true);
      for (int j = 0; j < 10; j++) {
        if(int.tryParse(data[(i * 10) + j]) != null)
          row.add(int.tryParse(data[(i * 10) + j])!);
      }
      dataIn2D.add(row);
    }
    print("parse(): dataIn2D = [$dataIn2D]");

    bool isOnTissue = dataIn2D[0][9] == 1; // on tissue if 1
    bool isAirCalNeeded = dataIn2D[1][9] == 1; // on tissue if 1
    int pressure = dataIn2D[6][9];
    int batteryPercent = dataIn2D[2][9];
    bool isSensorHung = dataIn2D[4][9] == 0;
    bool isAbnormal = false;
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 9; j++) {
        if (dataIn2D[i][j] > 40) {
          isAbnormal = true;
          break;
        }
      }
    }

    var scanDataResponse = ScanDataResponse(
      data,
      dataIn2D,
      isOnTissue,
      isAirCalNeeded,
      pressure,
      isAbnormal,
      batteryPercent,
      isSensorHung,
    );

    return scanDataResponse;
  }

  static String cmdVersionNumber = "!";
  static String cmdSensorSerialNumber = "_";
  static String cmdBattery = "#";
  static String cmdToggleScan = "^";
}

class Response {}

class BatteryResponse extends Response {
  double percent;

  BatteryResponse(this.percent);

  @override
  String toString() {
    return percent.toString();
  }

  static bool isValid(String rawData) {
    return rawData.contains("#") == true;
  }

  static BatteryResponse? parse(String rawData) {
    print("parse() called with: rawData = [$rawData]");
    if (isValid(rawData) != true) return null;
    return BatteryResponse(getBatteryPercent(rawData));
  }

  static double getBatteryPercent(String rawData) {
    double voltage =
        double.tryParse(RegExp("[0-9].[0-9]{2}").stringMatch(rawData) ?? "") ?? 0.0;
    double a = 3.5;
    double b = 5.0;

    return voltage > 3.5
        ? (((voltage - a) * 100) / (b - a)).ceilToDouble()
        : 0.0;
  }
}

class SensorSerialNumberResponse extends Response {
  String slNo;

  SensorSerialNumberResponse(this.slNo);

  @override
  String toString() {
    return slNo;
  }

  static bool isValid(String rawData) {
    return rawData.contains("_") == true;
  }

  static SensorSerialNumberResponse? parse(String rawData) {
    print("parse() called with: rawData = [$rawData]");
    if (rawData == null || isValid(rawData) != true) return null;
    return SensorSerialNumberResponse(getSlNo(rawData));
  }

  static String getSlNo(String rawData) {
    String slNo =
        RegExp("[0-9]+").stringMatch(rawData) ?? "";

    return slNo;
  }
}

class VersionResponse extends Response {
  String serialNumber;
  String versionNumber;

  VersionResponse(this.serialNumber, this.versionNumber);

  @override
  String toString() {
    return "Version: $versionNumber, Serial number: $serialNumber";
  }

  static bool isValid(String rawData) {
    return rawData.contains("SN=") == true;
  }

  static VersionResponse? parse(String rawData) {
    print("parse() called with: rawData = [$rawData]");
    if (rawData == null || isValid(rawData) != true) return null;

    String slNo = RegExp("[0-9A-Z]{7}").stringMatch(rawData) ?? "";
    String versionNumber = RegExp("v[0-9][.0-9]*").stringMatch(rawData) ?? "";
    return VersionResponse(slNo, versionNumber);
  }
}