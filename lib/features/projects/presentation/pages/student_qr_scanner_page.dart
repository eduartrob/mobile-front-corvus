import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/shared/widgets/corvus_top_bar.dart';

class StudentQRScannerPage extends StatefulWidget {
  const StudentQRScannerPage({super.key});

  @override
  State<StudentQRScannerPage> createState() => _StudentQRScannerPageState();
}

class _StudentQRScannerPageState extends State<StudentQRScannerPage> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final rawValue = barcode.rawValue!;
        // Expected format: corvus-join:<CODE>
        if (rawValue.startsWith('corvus-join:')) {
          final code = rawValue.substring('corvus-join:'.length);
          _hasScanned = true;
          // Pop the scanner page and return the code to the caller
          context.pop(code);
          break;
        } else {
          // If the QR code is just the code
          _hasScanned = true;
          context.pop(rawValue);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CorvusTopBar(
        titleWidget: Text('Escanear QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          // Overlay to guide the user
          Container(
            decoration: ShapeDecoration(
              shape: _ScannerOverlayShape(
                borderColor: Theme.of(context).colorScheme.primary,
                borderWidth: 4.0,
              ),
            ),
          ),
          const Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Apunta al código QR del proyecto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double overlayOpacity;

  const _ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 4.0,
    this.overlayOpacity = 0.5,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(0);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getClipPath(Rect rect) {
      final double width = rect.width;
      final double height = rect.height;
      final double size = width < height ? width * 0.7 : height * 0.7;
      final double left = (width - size) / 2;
      final double top = (height - size) / 2;

      return Path()
        ..addRect(Rect.fromLTWH(left, top, size, size));
    }

    return Path()
      ..addRect(rect)
      ..addPath(_getClipPath(rect), Offset.zero)
      ..fillType = PathFillType.evenOdd;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final Paint paint = Paint()
      ..color = Colors.black.withOpacity(overlayOpacity)
      ..style = PaintingStyle.fill;
    
    // Draw the dark background
    canvas.drawPath(getOuterPath(rect), paint);

    // Draw the borders
    final double width = rect.width;
    final double height = rect.height;
    final double size = width < height ? width * 0.7 : height * 0.7;
    final double left = (width - size) / 2;
    final double top = (height - size) / 2;
    
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    
    // Draw corners
    final double cornerSize = size * 0.1;
    final Path cornerPath = Path();

    // Top left
    cornerPath.moveTo(left, top + cornerSize);
    cornerPath.lineTo(left, top);
    cornerPath.lineTo(left + cornerSize, top);

    // Top right
    cornerPath.moveTo(left + size - cornerSize, top);
    cornerPath.lineTo(left + size, top);
    cornerPath.lineTo(left + size, top + cornerSize);

    // Bottom right
    cornerPath.moveTo(left + size, top + size - cornerSize);
    cornerPath.lineTo(left + size, top + size);
    cornerPath.lineTo(left + size - cornerSize, top + size);

    // Bottom left
    cornerPath.moveTo(left + cornerSize, top + size);
    cornerPath.lineTo(left, top + size);
    cornerPath.lineTo(left, top + size - cornerSize);

    canvas.drawPath(cornerPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) {
    return _ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
    );
  }
}
