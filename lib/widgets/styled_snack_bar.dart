import 'package:flutter/material.dart';

enum SnackBarType { error, warning, success }

class StyledSnackBar {
  static void show(
    BuildContext context,
    String text, {
    SnackBarType type = SnackBarType.success,
    Duration duration = const Duration(seconds: 5),
  }) {
    Color backgroundColor;

    switch (type) {
      case SnackBarType.error:
        backgroundColor = Colors.red[200]!;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.amber[200]!;
        break;
      case SnackBarType.success:
        backgroundColor = Colors.greenAccent;
        break;
    }
    final screenWidth = MediaQuery.of(context).size.width;

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          bottom: 50,
          left: screenWidth > 520 ? screenWidth * 1 / 5 : 20,
          right: screenWidth > 520 ? screenWidth * 1 / 5 : 20,
          child: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(8),
            color: backgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Center(
                child: Text(text, style: TextStyle(color: Colors.black)),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }
}
