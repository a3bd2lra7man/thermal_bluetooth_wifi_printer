import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:thermal_bluetooth_wifi_printer/thermal_bluetooth_wifi_printer.dart';
import '../tickets_examples/tickets_example.dart';

class WifiPrinters extends StatefulWidget {
  const WifiPrinters({super.key});

  @override
  State<WifiPrinters> createState() => _WifiPrintersState();
}

class _WifiPrintersState extends State<WifiPrinters> {
  WifiPrinter? printer;
  bool isConnected = false;
  TextEditingController ipController = TextEditingController(text: '192.168.');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text("Enter Printer Ip Address:"),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 20),
              Expanded(
                child: TextField(
                  controller: ipController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(onPressed: connect, child: const Text("Connect")),
              const SizedBox(width: 20),
            ],
          ),
          const Spacer(),
          if (isConnected) ElevatedButton(onPressed: printTest, child: const Text("print test")),
          const SizedBox(height: 20),
        ],
      ),
    ));
  }

  connect() async {
    var ip = ipController.text;
    showDialog(context: context, builder: (_) => _progressWidget("connecting"));
    printer = await WifiPrinter.init(ip: ip, paperSize: PaperSize.mm58);
    isConnected = await printer!.connect();
    Navigator.of(context).pop();
    if (!isConnected) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("failed to connect to printer with address $ip")));
    } else {}
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
}
