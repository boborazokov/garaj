import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_auto/core/auth/auth_guard.dart';
import 'package:my_auto/core/auth/pending_action.dart';
import 'package:my_auto/core/config/admin_config.dart';
import 'package:my_auto/core/routes/name.dart';
import 'package:my_auto/features/chat/chat_di.dart';

/// Single source of truth for admin chat copy + entry points.
///
/// The "admin chat" is a regular conversation between the current user and the
/// support account whose id is provisioned through `ADMIN_USER_ID` in `.env`.
/// It deliberately bypasses any new GraphQL surface — `createConversation`
/// already deduplicates threads per recipient — so the feature works the
/// moment the backend creates the support account.
class AdminChatStrings {
  AdminChatStrings._(this._code);

  factory AdminChatStrings.of(BuildContext context) {
    final code = Localizations.localeOf(context).languageCode;
    return AdminChatStrings._(code);
  }

  final String _code;

  /// Display name used everywhere (chat tile, app bar, fallback).
  /// Kept identical across locales so users always recognize the row.
  String get displayName => 'Admin';

  String get pinnedSubtitle {
    switch (_code) {
      case 'ru':
        return 'Связаться с поддержкой';
      case 'uz':
        return 'Yordam bilan bogʻlanish';
      default:
        return 'Tap to chat with support';
    }
  }

  String get notConfigured {
    switch (_code) {
      case 'ru':
        return 'Чат поддержки пока не настроен';
      case 'uz':
        return 'Yordam chati hali sozlanmagan';
      default:
        return 'Support chat is not configured yet';
    }
  }

  String get requestVerification {
    switch (_code) {
      case 'ru':
        return 'Запросить верификацию';
      case 'uz':
        return 'Tasdiqlashni soʻrash';
      default:
        return 'Request verification';
    }
  }

  String get requestVerificationHint {
    switch (_code) {
      case 'ru':
        return 'Получите бейдж «Проверен» — напишите админу.';
      case 'uz':
        return 'Tasdiqlangan belgisini olish uchun adminga yozing.';
      default:
        return 'Get the verified badge — message admin.';
    }
  }

  /// Pre-typed message inserted into the composer when the seller starts a
  /// verification request. The seller can edit before sending.
  String verificationRequestPrefill(String storeName) {
    final name = storeName.trim().isEmpty ? '—' : storeName.trim();
    switch (_code) {
      case 'ru':
        return 'Здравствуйте! Прошу верифицировать мой магазин «$name».';
      case 'uz':
        return 'Salom! «$name» doʻkonimni tasdiqlashingizni soʻrayman.';
      default:
        return 'Hello! Please verify my store "$name".';
    }
  }
}

/// Opens (or creates) the conversation with the admin support account and
/// pushes the chat detail screen on top of the navigation stack.
///
/// When [prefillText] is supplied it is forwarded to [ChatDetailScreen] which
/// pre-types it into the composer (the seller can still edit / cancel).
class AdminChat {
  AdminChat._();

  /// Whether the current build has a usable admin user id wired up.
  static bool get isAvailable => AdminConfig.isConfigured;

  static Future<void> open(
    BuildContext context, {
    String? prefillText,
  }) async {
    final strings = AdminChatStrings.of(context);
    if (!isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.notConfigured)),
      );
      return;
    }

    final ok = await AuthGuard.requireAuth(
      context,
      pending: const PendingRoute(path: RoutesName.chats),
    );
    if (!ok || !context.mounted) return;

    try {
      final conversation = await chatRepository.createConversation(
        recipientId: AdminConfig.userId,
      );
      if (!context.mounted) return;

      context.push(
        '${RoutesName.chatDetail}/${conversation.id}',
        extra: <String, Object?>{
          'peerTitle': strings.displayName,
          if (prefillText != null && prefillText.trim().isNotEmpty)
            'prefillText': prefillText,
        },
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.notConfigured)),
      );
    }
  }
}
