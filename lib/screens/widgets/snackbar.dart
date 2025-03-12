import 'package:flutter/material.dart';

class SnackbarService {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showMessage(
    String message, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 2),
    bool loading = false,
  }) {
    messengerKey.currentState!.removeCurrentSnackBar();
    messengerKey.currentState!.showSnackBar(
      SnackBar(
        content:
            loading
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis, // Prevent overflow
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                )
                : Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600, // Bolder text for emphasis
                  ),
                ),
        duration: loading ? const Duration(minutes: 1) : duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Smoother corners
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 10, // Add a shadow for depth
        backgroundColor: const Color(0xFF333333), // Use a modern dark shade
        action: action,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
