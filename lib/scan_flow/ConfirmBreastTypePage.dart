import 'package:provider/provider.dart';
import 'package:bluetooth_sample/Models.dart';
import 'package:bluetooth_sample/scan_flow/bloc/ScanStreamBloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConfirmBreastTypePage extends StatefulWidget {
  final void Function() onBreastTypeConfirmed;

  ConfirmBreastTypePage({Key? key, required this.onBreastTypeConfirmed,});

  @override
  State<StatefulWidget> createState() => ConfirmBreastTypePageState();
}

class ConfirmBreastTypePageState extends State<ConfirmBreastTypePage> {
  ScanStreamBloc? bloc;
  ScanDetails? scanDetails;

  @override
  void initState() {
    bloc = context.read<ScanStreamBloc>();
    scanDetails = bloc?.scanDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Center(
        child: Column(
          children: [
            Text(scanDetails?.breastType ?? "")
          ],
        ),
      ),
      Positioned(
          bottom: 16,
          right: 16,
          child: MaterialButton(
            child: Text("Confirm"),
            onPressed: () {
              widget.onBreastTypeConfirmed();
            },
          )),
      Positioned(
          bottom: 16,
          left: 16,
          child: MaterialButton(
            child: Text("Re-select"),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
    ]);
  }
}
