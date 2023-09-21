import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';

Future<List<int>> testTicket(PaperSize paperSize) async {
  List<int> bytes = [];
  // Using default profile
  final profile = await CapabilityProfile.load();
  final generator = Generator(paperSize, profile);
  //bytes += generator.setGlobalFont(PosFontType.fontA);
  bytes += generator.reset();

  final ByteData data = await rootBundle.load('assets/mylogo.jpg');
  final Uint8List bytesImg = data.buffer.asUint8List();
  img.Image? image = img.decodeImage(bytesImg);

  if (Platform.isIOS) {
    // Resizes the image to half its original size and reduces the quality to 80%
    final resizedImage = img.copyResize(image!,
        width: image.width ~/ 1.3, height: image.height ~/ 1.3, interpolation: img.Interpolation.nearest);
    final bytesimg = Uint8List.fromList(img.encodeJpg(resizedImage));
    //image = img.decodeImage(bytesimg);
  }

  //Using `ESC *`
  bytes += generator.image(image!);

  bytes += generator.text('Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
  bytes += generator.text('Special 1: ñÑ àÀ èÈ éÉ üÜ çÇ ôÔ', styles: PosStyles(codeTable: 'CP1252'));
  bytes += generator.text('Special 2: blåbærgrød', styles: PosStyles(codeTable: 'CP1252'));

  bytes += generator.text('Bold text', styles: PosStyles(bold: true));
  bytes += generator.text('Reverse text', styles: PosStyles(reverse: true));
  bytes += generator.text('Underlined text', styles: PosStyles(underline: true), linesAfter: 1);
  bytes += generator.text('Align left', styles: PosStyles(align: PosAlign.left));
  bytes += generator.text('Align center', styles: PosStyles(align: PosAlign.center));
  bytes += generator.text('Align right', styles: PosStyles(align: PosAlign.right), linesAfter: 1);

  bytes += generator.row([
    PosColumn(
      text: 'col3',
      width: 3,
      styles: PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col6',
      width: 6,
      styles: PosStyles(align: PosAlign.center, underline: true),
    ),
    PosColumn(
      text: 'col3',
      width: 3,
      styles: PosStyles(align: PosAlign.center, underline: true),
    ),
  ]);

  //barcode

  final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
  bytes += generator.barcode(Barcode.upcA(barData));

  //QR code
  bytes += generator.qrcode('example.com');

  bytes += generator.text(
    'Text size 50%',
    styles: PosStyles(
      fontType: PosFontType.fontB,
    ),
  );
  bytes += generator.text(
    'Text size 100%',
    styles: PosStyles(
      fontType: PosFontType.fontA,
    ),
  );
  bytes += generator.text(
    'Text size 200%',
    styles: PosStyles(
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );

  bytes += generator.feed(4);
  bytes += generator.cut();
  return bytes;
}
