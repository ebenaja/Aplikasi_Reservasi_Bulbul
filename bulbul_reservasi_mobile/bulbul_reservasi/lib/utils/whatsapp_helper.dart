import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppHelper {
  /// Open WhatsApp chat with [phone] (in international format, no +) and optional [message].
  /// Tries the WhatsApp app first, falls back to web `https://wa.me/` if not available.
  static Future<void> openWhatsApp({required BuildContext context, required String phone, String? message}) async {
    final encodedMsg = Uri.encodeComponent(message ?? '');

    final uriApp = Uri.parse('whatsapp://send?phone=$phone&text=$encodedMsg');
    final uriWeb = Uri.parse('https://wa.me/$phone${message != null && message.isNotEmpty ? '?text=$encodedMsg' : ''}');

    try {
      if (await canLaunchUrl(uriApp)) {
        await launchUrl(uriApp, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(uriWeb)) {
        await launchUrl(uriWeb, mode: LaunchMode.externalApplication);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tidak dapat membuka WhatsApp')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuka WhatsApp')));
    }
  }
}
