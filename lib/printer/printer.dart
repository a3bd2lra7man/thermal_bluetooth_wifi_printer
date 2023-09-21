import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:image/image.dart' as img;

abstract class Printer {
  final String id;
  late final PaperSize paperSize;
  late CapabilityProfile profile;
  late Generator generator;

  Printer(this.id);

  Future<Printer> initialize(Printer printer, PaperSize paperSize) async {
    printer.profile = await CapabilityProfile.load();
    printer.generator = Generator(paperSize, printer.profile);
    printer.paperSize = paperSize;
    return printer;
  }

  Future<bool> connect();
  Future<bool> get isConnected;
  Future<void> printBytes(List<int> ticket);
  Future<void> disconnect();

  Future<void> beep({int n = 3, PosBeepDuration duration = PosBeepDuration.beep450ms}) async {
    printBytes(generator.beep(n: n, duration: duration));
  }

  Future<void> print({required List<int> ticket, bool isKanji = false}) {
    return printBytes(generator.rawBytes(ticket, isKanji: isKanji));
  }

  Future<void> printImage({required img.Image image, bool isKanji = false}) {
    return printBytes(generator.image(image));
  }

  Future<void> printText({required String text, PosStyles style = const PosStyles()}) {
    return printBytes(generator.text(text, styles: style));
  }

  Future<void> qrcode(
    String text, {
    PosAlign align = PosAlign.center,
    QRSize size = QRSize.size4,
    QRCorrection cor = QRCorrection.L,
  }) {
    List<int> bytes = [];
    QRCode qr = QRCode(text, size, cor);
    bytes += qr.bytes;
    return printBytes(bytes);
  }

  void feed(int n) {
    printBytes(generator.emptyLines(n));
  }
}
