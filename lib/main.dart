import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf_flutter/pdf_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
//import 'package:pdf_flutter/pdf_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML QR Reader',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
      ),
      home: QrScan(),
    );
  }
}

class QrScan extends StatefulWidget {
  @override
  _QrScanState createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget _scanner() {
    if (result != null) {
      return AlertDialog(
        title: Text('Abrir'),
        content: Text('${result!.code}?'),
        actions: [
          TextButton(
            onPressed: () {
              _openPdf(
                  title: '${result!.code}',
                  child: PDF.asset('assets/pdf/${result!.code}'));
              result = null;
              setState(() {});
            },
            child: Text('OK'),
          ),
          TextButton(
              onPressed: () {
                result = null;
                setState(() {});
              },
              child: Text('No'))
        ],
      );
    } else {
      return _buildQrView(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ML QR Reader',
          style: TextStyle(
              fontFamily: 'ML', color: Color.fromRGBO(45, 50, 119, 1)),
        ),
        backgroundColor: Color.fromRGBO(255, 238, 96, 1),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await controller?.toggleFlash();
            setState(() {});
          },
          child: Icon(Icons.highlight_outlined)),
      body: Center(
        child: Expanded(
          flex: 3,
          child: _scanner(),
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 350.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    var qrScannerOverlayShape = QrScannerOverlayShape(
        borderColor: Colors.blue,
        borderRadius: 5,
        borderLength: 30,
        borderWidth: 5,
        cutOutSize: scanArea);
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: qrScannerOverlayShape,
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _openPdf({String? title, Widget? child}) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(title!)),
                  body: Center(
                    child: child,
                  ),
                )));
  }
}
