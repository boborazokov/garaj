import { PushBody } from './push.types';

/**
 * Server-side push notification templates.
 *
 * Kept intentionally small (English source strings) — the mobile client
 * builds the user-facing notification when the app is in foreground
 * using its own l10n bundle, so these strings are only seen on the
 * lock screen / system tray when the app isn't running yet. If/when we
 * need full server-side i18n, add a locale parameter and a small
 * Handlebars-driven dictionary here.
 */
export const NotificationTemplates = {
  newMessage(senderName: string, preview: string, hasImages: boolean): PushBody {
    const fallback = hasImages ? 'Sent a photo' : 'New message';
    const trimmed = (preview || '').trim();
    return {
      title: senderName || 'AutoRin',
      body: trimmed.length > 0 ? trimmed.slice(0, 140) : fallback,
    };
  },

  newOrderReply(
    orderTitle: string,
    replierName: string,
    responsePreview?: string,
  ): PushBody {
    const name = (replierName || 'Seller').trim();
    const preview = (responsePreview || '').trim().slice(0, 140);
    const title = preview.length > 0 ? name : 'New reply on your request';
    const body =
      preview.length > 0
        ? preview
        : `${name} responded to "${(orderTitle || 'your request').slice(0, 80)}"`;
    return { title, body };
  },

  favoriteMatched(partName: string): PushBody {
    return {
      title: 'A match for your favorite',
      body: `${partName.slice(0, 100)} is available now.`,
    };
  },

  promotedExpired(partName: string): PushBody {
    return {
      title: 'Promotion expired',
      body: `"${partName.slice(0, 100)}" is no longer promoted.`,
    };
  },

  sellerResponse(partName: string, sellerName: string): PushBody {
    return {
      title: `${sellerName} replied`,
      body: `About "${partName.slice(0, 100)}"`,
    };
  },

  newFollower(followerName: string): PushBody {
    const name = (followerName || 'Someone').trim();
    return {
      title: 'New follower',
      body: `${name} started following your store.`,
    };
  },

  userVerified(): PushBody {
    return {
      title: 'You are verified',
      body: 'Your account is now verified by the AutoRin team.',
    };
  },
};
