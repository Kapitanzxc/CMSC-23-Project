import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

// QR Code Scanner Page from the flutter documentation
class QRCodeScannerPage extends StatefulWidget {
  const QRCodeScannerPage({super.key});

  @override
  State<QRCodeScannerPage> createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  // Variables
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  // Bool variable to prevent multiple navigation pops
  bool hasResult = false;

  // Dispossing controllers
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            // Creates the QR Code
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
        ],
      ),
    );
  }

// Function for monitoring controller changes
  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    // If controller scanned a data:
    controller.scannedDataStream.listen(
      (scanData) {
        setState(() {
          // Storing the scanned data to result
          result = scanData;
          if (!hasResult) {
            // If result have data:
            if (result != null &&
                result!.code != null &&
                result!.code!.isNotEmpty) {
              // Pop the qr scanner and return the code
              Navigator.pop(context, result!.code);
              hasResult = true;
            } else {
              print('Scanned code is empty');
            }
          }
        });
      },
      onError: (error) {
        print('Error scanning QR code: $error');
      },
    );
  }
}
