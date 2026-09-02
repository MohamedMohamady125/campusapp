import 'package:campusconnect/design_system/material.dart';
import 'package:campusconnect/design_system/theme/app_text_styles.dart';
import 'package:campusconnect/design_system/theme/app_tokens.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// The requester's Mobile Order pickup-QR flow.
///
/// A requester places and pays their OWN campus Mobile Order, then attaches the
/// QR so the accepted runner can present it at the counter. Sending a raw
/// screenshot through chat fails because image compression degrades the QR's
/// error-correction blocks; instead we decode the screenshot to its payload
/// string here and re-render a pristine code on the runner's side.
Future<String?> pickMobileOrderCode(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final XFile? file;
  try {
    file = await ImagePicker().pickImage(source: ImageSource.gallery);
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text("Couldn't open your photos.")),
    );
    return null;
  }
  if (file == null) return null;

  final controller = MobileScannerController();
  try {
    final capture = await controller.analyzeImage(file.path);
    final raw = capture?.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't find a QR code in that image. Pick a clear, "
            'uncropped screenshot of your Mobile Order code.',
          ),
        ),
      );
      return null;
    }
    return raw;
  } on Object {
    messenger.showSnackBar(
      const SnackBar(content: Text("Couldn't read that QR code.")),
    );
    return null;
  } finally {
    await controller.dispose();
  }
}

/// Opens the runner's full-screen, high-contrast re-rendered pickup QR.
Future<void> showPickupQr(
  BuildContext context, {
  required String code,
  required String requesterName,
}) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PickupQrScreen(code: code, requesterName: requesterName),
    ),
  );
}

/// Full-screen pickup code: crisp QR on a forced-white field so the counter
/// scanner reads it even at an angle. Shown only to a runner who has accepted
/// the order (the server gates the code's reveal).
class PickupQrScreen extends StatelessWidget {
  const PickupQrScreen({
    required this.code,
    required this.requesterName,
    super.key,
  });

  final String code;
  final String requesterName;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    // Force a light field regardless of app theme — dark-mode QRs scan poorly.
    return Theme(
      data: ThemeData.light(useMaterial3: true),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          title: Text("$requesterName's pickup"),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(tokens.space6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show this at the counter',
                    style: AppTextStyles.subheading.copyWith(
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: tokens.space6),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: tokens.brMd,
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(tokens.space4),
                      child: QrImageView(
                        data: code,
                        size: 280,
                        backgroundColor: Colors.white,
                        // High error correction survives glare/angle at a
                        // counter scanner.
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                      ),
                    ),
                  ),
                  SizedBox(height: tokens.space5),
                  Text(
                    "This is $requesterName's own paid Mobile Order. Turn "
                    'your screen brightness up all the way so it scans.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
