import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:beautician_app/controllers/vendors/booking/qrCodeController.dart';
import 'package:beautician_app/views/user/nav_bar_screens/appointment/tabs/userActivationScreen.dart';

class QRScannerScreen extends StatefulWidget {
  final String userId;
  final String qrCode;

  const QRScannerScreen({Key? key, required this.userId, required this.qrCode})
    : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final qrCtrl = Get.find<SocketController>(); // ✅ Use global instance
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? cameraCtrl;
  bool scanned = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    qrCtrl.initSocket().then((_) {
      qrCtrl.register(widget.userId, "user");

      qrCtrl.onBookingActivated((data) {
        if (mounted) _showSnackbar("Booking Activated!", Colors.green);
      });

      qrCtrl.onBookingCompleted((data) {
        if (mounted) _showSnackbar("Booking Completed!", Colors.blue);
      });
    });
  }

  Future<void> _processScannedCode(String code) async {
    if (_isProcessing) return;
    _isProcessing = true;

    if (!_isValidQRCode(code)) {
      _showSnackbar("Invalid QR code", Colors.red);
      scanned = false;
      await cameraCtrl?.resumeCamera();
      _isProcessing = false;
      return;
    }

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await qrCtrl.scanQrCode(code);
      print('📦 Scan Response: $response');

      if (response['status'] == 'success') {
        _showSnackbar("Booking Verified!", Colors.green);

        Get.back(); // Close loading
        Get.to(
          () => UserActivationScreen(
            bookingId: response['data']['_id'], // ✅ Correct booking ID
            userId: widget.userId,
            vendorId: response['data']['vendor'],
          ),
        );
      } else {
        throw Exception(response['message'] ?? "Invalid booking QR code");
      }
    } catch (e) {
      Get.back();
      _showSnackbar(e.toString().replaceAll('Exception: ', ''), Colors.red);
    } finally {
      scanned = false;
      await cameraCtrl?.resumeCamera();
      _isProcessing = false;
    }
  }

  bool _isValidQRCode(String code) {
    return code.isNotEmpty && code.length > 10;
  }

  void _onQRViewCreated(QRViewController controller) {
    cameraCtrl = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!scanned && scanData.code != null && mounted) {
        scanned = true;
        await cameraCtrl?.pauseCamera();
        await _processScannedCode(scanData.code!);
        print('📸 QR Code Scanned: ${scanData.code}');
      }
    });
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    cameraCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Colors.blue,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 10,
              cutOutSize: MediaQuery.of(context).size.width * 0.7,
            ),
          ),
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Scan vendor's QR code",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
