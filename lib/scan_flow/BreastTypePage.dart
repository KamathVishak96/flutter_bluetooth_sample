import 'dart:developer';
import 'package:provider/provider.dart';
import 'package:bluetooth_sample/Models.dart';
import 'package:bluetooth_sample/scan_flow/bloc/ScanStreamBloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BreastTypePage extends StatefulWidget {
  final void Function() onBreastTypeSelected;

  const BreastTypePage({Key? key, required this.onBreastTypeSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BreastTypePageState();
}

class BreastTypePageState extends State<BreastTypePage> {
  ScanDetails? scanDetails;

  @override
  void initState() {
    scanDetails = context.read<ScanStreamBloc>().scanDetails;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    log("Building BreastTypePage");
    return Column(
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              ListTile(title:Text("Type 1"), onTap: () {
                scanDetails?.breastType = "Type 1";
                widget.onBreastTypeSelected();
              },),
              ListTile(title:Text("Type 2"), onTap: () {
                scanDetails?.breastType = "Type 2";
                widget.onBreastTypeSelected();
              },),
              ListTile(title:Text("Type 3"), onTap: () {
                scanDetails?.breastType = "Type 3";
                widget.onBreastTypeSelected();
              },),
              ListTile(title:Text("Type 4"), onTap: () {
                scanDetails?.breastType = "Type 4";
                widget.onBreastTypeSelected();
              },),
            ],
          )
        ]);
  }

}