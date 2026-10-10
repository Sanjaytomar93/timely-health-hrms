import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final src = img.decodeImage(File('assets/images/payslip_seal.png').readAsBytesSync())!;
  print('${src.width}x${src.height}');
  var minX = src.width, maxX = 0, minY = src.height, maxY = 0;
  for (var y = 0; y < src.height; y++) {
    for (var x = 0; x < src.width; x++) {
      final p = src.getPixel(x, y);
      if (p.a < 20) continue;
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }
  }
  print('opaque bounds $minX,$minY $maxX,$maxY');
  for (var x = minX; x < minX + 15 && x < src.width; x++) {
    var dark = 0;
    for (var y = minY; y <= maxY; y++) {
      final p = src.getPixel(x, y);
      if (p.a > 20 && p.r < 40 && p.g < 40 && p.b < 40) dark++;
    }
    print('x=$x dark=$dark');
  }
}
