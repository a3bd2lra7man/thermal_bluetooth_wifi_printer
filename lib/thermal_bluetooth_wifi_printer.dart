import 'dart:io';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'printer/printer.dart';

class WifiPrinter extends Printer {
  final String ip;
  Socket? _socket;

  static Future<WifiPrinter> init({required String ip, required PaperSize paperSize}) async {
    var printer = WifiPrinter._(ip);
    return (await printer.initialize(printer, paperSize)) as WifiPrinter;
  }

  WifiPrinter._(this.ip) : super(ip);

  @override
  Future<bool> connect({int? port, Duration timeout = const Duration(seconds: 5)}) async {
    try {
      _socket = await Socket.connect(ip, port ?? 9100, timeout: timeout);
      _socket?.add(generator.reset());
      _socket?.listen(
        (event) {},
        onDone: () {
          _socket = null;
        },
      );
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Future<void> disconnect({int? delayMs}) async {
    _socket?.destroy();
    if (delayMs != null) {
      await Future.delayed(Duration(milliseconds: delayMs), () => null);
    }
  }

  @override
  Future<bool> get isConnected async => _socket != null;

  @override
  Future<void> printBytes(List<int> ticket) async {
    _socket?.add(ticket);
  }
}

class BluetoothPrinter extends Printer {
  final String macAddress;

  static Future<BluetoothPrinter> init({required String macAddress, required PaperSize paperSize}) async {
    var printer = BluetoothPrinter._(macAddress);
    return (await printer.initialize(printer, paperSize)) as BluetoothPrinter;
  }

  BluetoothPrinter._(this.macAddress) : super(macAddress);

  @override
  Future<bool> connect() async {
    return await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  @override
  Future<void> disconnect() async {
    await PrintBluetoothThermal.disconnect;
  }

  @override
  Future<bool> get isConnected async => await PrintBluetoothThermal.connectionStatus;

  @override
  Future<void> printBytes(List<int> ticket) async {
    await PrintBluetoothThermal.writeBytes(ticket);
  }
}
