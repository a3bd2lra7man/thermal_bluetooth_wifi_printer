import 'package:flutter/material.dart';
import 'package:thermal_bluetooth_wifi_printer_example/bluetooth/bluetooth_printers.dart';

import 'wifi/wifi_printers.dart';

void main(List<String> args) {
  runApp(ThermalPrinterExample());
}

class ThermalPrinterExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ThermalPrinterPage(),
    );
  }
}

class ThermalPrinterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Thermal Printer"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Wifi'),
              Tab(text: 'Bluetooth'),
            ],
          ),
        ),
        body: TabBarView(children: [
          WifiPrinters(),
          BluetoothPrinters(),
        ]),
      ),
    );
  }
}
