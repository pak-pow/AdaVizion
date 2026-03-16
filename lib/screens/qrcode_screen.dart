import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScreen extends StatefulWidget {
  const QRCodeScreen({super.key});

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  // this allows us to control the camera and listen for QR code scans
  final MobileScannerController _cameraController = MobileScannerController();
  bool isScanning = true;

  // function to allow to navigate to different screens based on the scanned QR code value
  void _showOptionsDialog(String codeValue) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Landmark Detected!"),
          content: Text(
            "You have scanned: $codeValue\n\nWhat would you like to do?",
          ),
          actions: [
            // This button allows user to go back to DashboardScreen
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Go to Dashboard"),
            ),
            // This button allows the user to proceed to Landmark Details Screen (not implemented yet)
            // Temporarily reroutes to DashbordScreen with a print statement for demonstration purposes.
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Landmark Fun Facts!"),
                      content: Text("Navigating to Fun Facts with: $codeValue"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text("Close"),
                        ),
                      ],
                    );
                  },
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text("View Fun Facts"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "EUventure",
          style: TextStyle(
            color: Color(0xFF800000),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),

      body: MobileScanner(
        controller: _cameraController,
        onDetect: (capture) {
          if (isScanning) {
            final barcode = capture.barcodes.first;

            if (barcode.rawValue != null) {
              setState(
                () => isScanning = false,
              ); // this prevents multiple scans
              _cameraController.stop(); // stops the cam after successful scan

              _showOptionsDialog(barcode.rawValue!);
            }
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
