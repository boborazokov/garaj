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

  newOrderMatched(
    orderTitle: string,
    categoryName?: string,
    budget?: number,
    currency?: string,
  ): PushBody {
    const cat = (categoryName || '').trim();
    const title = cat.length > 0 ? `New request · ${cat.slice(0, 40)}` : 'New matching request';
    const money =
      budget != null && budget > 0
        ? ` · ${budget}${currency ? ` ${currency}` : ''}`
        : '';
    return {
      title,
      body: `"${(orderTitle || 'Buyer request').slice(0, 90)}"${money}`,
    };
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

  userVerified(): PushBody {
    return {
      title: 'You are verified',
      body: 'Your account is now verified by the AutoRin team.',
    };
  },

  walletTopUp(amountLabel: string): PushBody {
    return {
      title: 'Wallet topped up',
      body: `+${amountLabel} added to your balance.`,
    };
  },

  walletSpend(amountLabel: string, reason: string): PushBody {
    const why = (reason || 'Wallet charge').trim().slice(0, 120);
    return {
      title: 'Wallet charge',
      body: `−${amountLabel} · ${why}`,
    };
  },
};

export function formatMoneyLabel(amount: number, currency = 'UZS'): string {
  const n = Math.abs(Math.floor(amount));
  const digits = n.toString();
  const parts: string[] = [];
  for (let i = digits.length; i > 0; i -= 3) {
    parts.unshift(digits.slice(Math.max(0, i - 3), i));
  }
  return `${parts.join(' ')} ${currency}`;
}
