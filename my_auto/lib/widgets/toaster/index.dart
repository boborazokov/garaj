import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:my_auto/main.dart';

class Toaster {
  static void success(String message, {BuildContext? context}) =>
      _show(message, Icons.check_rounded, Colors.green[700]!, context);

  static void error(String message, {BuildContext? context}) => _show(
      message,
      Icons.close_rounded,
      (context != null ? Theme.of(context).colorScheme.error : Colors.red),
      context);

  static void _show(
      String message, IconData icon, Color bgColor, BuildContext? context) {
    final messenger = context != null
        ? ScaffoldMessenger.of(context)
        : scaffoldMessengerKey.currentState;
    if (kDebugMode) {
      debugPrint('[Toaster] $message');
    }
    messenger?.clearSnackBars();
    messenger?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
