import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:thermal_bluetooth_wifi_printer/thermal_bluetooth_wifi_printer.dart';

import '../tickets_examples/tickets_example.dart';

class BluetoothPrinters extends StatefulWidget {
  const BluetoothPrinters({super.key});

  @override
  State<BluetoothPrinters> createState() => _BluetoothPrintersState();
}

class _BluetoothPrintersState extends State<BluetoothPrinters> {
  List<BluetoothInfo> devices = [];
  BluetoothPrinter? printer;
  bool isConnected = false;
  bool isScanning = false;
  String connectedMacAddress = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: isScanning ? null : scan,
        child: isScanning ? const CircularProgressIndicator() : const Text("Scan"),
      ),
      body: devices.isEmpty
          ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [Text("No Devices")],
            )
          : ListView(
              children: devices
                  .map((device) => ListTile(
                        onTap: () => connect(device),
                        leading: connectedMacAddress == device.macAdress ? Text("connected") : null,
                        title: Text(device.name),
                        subtitle: Text(device.macAdress),
                        trailing: connectedMacAddress == device.macAdress
                            ? SizedBox(
                                width: 80, child: ElevatedButton(onPressed: printTest, child: Text("print test")))
                            : ElevatedButton(onPressed: () => connect(device), child: Text("Connect")),
                      ))
                  .toList(),
            ),
    );
  }

  connect(BluetoothInfo info) async {
    showDialog(context: context, builder: (_) => _progressWidget("connecting"));
    printer = await BluetoothPrinter.init(macAddress: info.macAdress, paperSize: PaperSize.mm58);
    isConnected = await printer!.connect();
    Navigator.of(context).pop();
    if (isConnected) {
      connectedMacAddress = info.macAdress;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("failed to connect to ${info.name} with address ${info.macAdress}")));
    }
    setState(() {});
  }

  Widget _progressWidget(String text) => Center(
        child: SizedBox(
          height: 80,
          width: 80,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Text(text),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      );

  void printTest() async {
    List<int> ticket = await testTicket(printer!.paperSize);
    await printer?.printBytes(ticket);
  }

  void scan() async {
    isScanning = true;
    setState(() {});
    await Permission.bluetooth.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothScan.request();
    devices = await PrintBluetoothThermal.pairedBluetooths;
    isScanning = false;
    setState(() {});
  }
}
