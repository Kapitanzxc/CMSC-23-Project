import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tolentino_mini_project/formatting/formatting.dart';

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
        centerTitle: true,
        title: Text('QR Code Scanner',
            style: Formatting.semiBoldStyle.copyWith(
              fontSize: 24,
              color: Formatting.black,
            )),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            // Creates the QR Code Scanner
            child: _buildQrView(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // Scanning area based on screen dimenions
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
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
