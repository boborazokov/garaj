import { useMemo, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { Wallet } from "lucide-react";
import {
  ADMIN_CREDIT_WALLET,
  ADMIN_WALLET,
  ADMIN_WALLET_TRANSACTIONS,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import { USER_INFO_COLORS, USER_INFO_TEXTS } from "../../constants";
import { walletPoolLabel, walletTxTypeLabel } from "../../helpers";

type WalletData = {
  _id: string;
  mainBalance: number;
  bonusBalance: number;
  availableTotal: number;
  currency: string;
};

type WalletTx = {
  _id: string;
  type: string;
  pool: string;
  amount: number;
  status: string;
  note?: string | null;
  createdAt: string;
};

function formatUzs(value: number, language: string) {
  return `${value.toLocaleString(
    language === "uz" ? "uz-UZ" : language === "en" ? "en-US" : "ru-RU",
  )} UZS`;
}

export function UserWalletCard({ userId }: { userId: string }) {
  const { t, language } = useLanguage();
  const [pool, setPool] = useState<"MAIN" | "BONUS">("MAIN");
  const [amount, setAmount] = useState("10000");
  const [note, setNote] = useState("");
  const [open, setOpen] = useState(false);

  const walletQuery = useQuery<{ adminWallet: WalletData }>(ADMIN_WALLET, {
    variables: { userId },
    skip: !userId,
    fetchPolicy: "cache-and-network",
  });

  const txQuery = useQuery<{ adminWalletTransactions: WalletTx[] }>(
    ADMIN_WALLET_TRANSACTIONS,
    {
      variables: { userId, limit: 20 },
      skip: !userId,
      fetchPolicy: "cache-and-network",
    },
  );

  const [creditWallet, { loading: crediting }] = useMutation(ADMIN_CREDIT_WALLET);

  const wallet = walletQuery.data?.adminWallet;
  const txs = txQuery.data?.adminWalletTransactions ?? [];

  const balances = useMemo(
    () => [
      {
        label: t(USER_INFO_TEXTS.walletMain),
        value: formatUzs(wallet?.mainBalance ?? 0, language),
      },
      {
        label: t(USER_INFO_TEXTS.walletBonus),
        value: formatUzs(wallet?.bonusBalance ?? 0, language),
      },
      {
        label: t(USER_INFO_TEXTS.walletTotal),
        value: formatUzs(wallet?.availableTotal ?? 0, language),
      },
    ],
    [wallet, language, t],
  );

  async function handleCredit() {
    const parsed = Number.parseInt(amount.replace(/\s/g, ""), 10);
    if (!Number.isFinite(parsed) || parsed < 1) return;
    await creditWallet({
      variables: {
        userId,
        pool,
        amount: parsed,
        note: note.trim() || undefined,
      },
    });
    setOpen(false);
    setNote("");
    await Promise.all([walletQuery.refetch(), txQuery.refetch()]);
  }

  return (
    <section
      className="rounded-[10px] border bg-white p-4"
      style={{ borderColor: USER_INFO_COLORS.border }}
    >
      <div className="mb-3 flex items-center justify-between gap-3">
        <div className="flex items-center gap-2">
          <span
            className="flex size-8 items-center justify-center rounded-full"
            style={{ background: USER_INFO_COLORS.accentSoft, color: USER_INFO_COLORS.accent }}
          >
            <Wallet className="size-4" strokeWidth={1.75} />
          </span>
          <h2
            className="text-[15px] font-semibold"
            style={{ color: USER_INFO_COLORS.text }}
          >
            {t(USER_INFO_TEXTS.walletTitle)}
          </h2>
        </div>
        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          className="h-8 rounded-[8px] px-3 text-[13px] font-medium text-white"
          style={{ background: USER_INFO_COLORS.accent }}
        >
          {t(USER_INFO_TEXTS.walletCredit)}
        </button>
      </div>

      {walletQuery.loading && !wallet ? (
        <p className="text-sm" style={{ color: USER_INFO_COLORS.muted }}>
          {t(USER_INFO_TEXTS.loading)}
        </p>
      ) : (
        <div className="grid grid-cols-1 gap-2 sm:grid-cols-3">
          {balances.map((row) => (
            <div
              key={row.label}
              className="rounded-[8px] border px-3 py-2.5"
              style={{ borderColor: USER_INFO_COLORS.border }}
            >
              <p className="text-[12px]" style={{ color: USER_INFO_COLORS.muted }}>
                {row.label}
              </p>
              <p
                className="mt-1 text-[15px] font-semibold"
                style={{ color: USER_INFO_COLORS.text }}
              >
                {row.value}
              </p>
            </div>
          ))}
        </div>
      )}

      {open && (
        <div
          className="mt-3 space-y-2 rounded-[8px] border p-3"
          style={{ borderColor: USER_INFO_COLORS.border }}
        >
          <label className="block text-[12px]" style={{ color: USER_INFO_COLORS.muted }}>
            {t(USER_INFO_TEXTS.walletPool)}
            <select
              className="mt-1 h-9 w-full rounded-[8px] border px-2 text-sm"
              value={pool}
              onChange={(e) => setPool(e.target.value as "MAIN" | "BONUS")}
            >
              <option value="MAIN">{t(USER_INFO_TEXTS.walletMain)}</option>
              <option value="BONUS">{t(USER_INFO_TEXTS.walletBonus)}</option>
            </select>
          </label>
          <label className="block text-[12px]" style={{ color: USER_INFO_COLORS.muted }}>
            {t(USER_INFO_TEXTS.walletAmount)}
            <input
              className="mt-1 h-9 w-full rounded-[8px] border px-2 text-sm"
              value={amount}
              onChange={(e) => setAmount(e.target.value)}
              inputMode="numeric"
            />
          </label>
          <label className="block text-[12px]" style={{ color: USER_INFO_COLORS.muted }}>
            {t(USER_INFO_TEXTS.walletNote)}
            <input
              className="mt-1 h-9 w-full rounded-[8px] border px-2 text-sm"
              value={note}
              onChange={(e) => setNote(e.target.value)}
            />
          </label>
          <div className="flex justify-end gap-2 pt-1">
            <button
              type="button"
              className="h-8 rounded-[8px] border px-3 text-[13px]"
              onClick={() => setOpen(false)}
            >
              {t(USER_INFO_TEXTS.walletCancel)}
            </button>
            <button
              type="button"
              disabled={crediting}
              className="h-8 rounded-[8px] px-3 text-[13px] font-medium text-white disabled:opacity-60"
              style={{ background: USER_INFO_COLORS.accent }}
              onClick={() => void handleCredit()}
            >
              {t(USER_INFO_TEXTS.walletSave)}
            </button>
          </div>
        </div>
      )}

      <div className="mt-4">
        <h3
          className="mb-2 text-[13px] font-semibold"
          style={{ color: USER_INFO_COLORS.textSecondary }}
        >
          {t(USER_INFO_TEXTS.walletHistory)}
        </h3>
        {txs.length === 0 ? (
          <p className="text-sm" style={{ color: USER_INFO_COLORS.muted }}>
            {t(USER_INFO_TEXTS.walletEmptyTx)}
          </p>
        ) : (
          <ul className="space-y-1.5">
            {txs.map((tx) => (
              <li
                key={tx._id}
                className="flex items-center justify-between gap-3 rounded-[8px] border px-3 py-2 text-[13px]"
                style={{ borderColor: USER_INFO_COLORS.border }}
              >
                <div className="min-w-0">
                  <p className="truncate font-medium" style={{ color: USER_INFO_COLORS.text }}>
                    {walletTxTypeLabel(tx.type, t)} · {walletPoolLabel(tx.pool, t)}
                  </p>
                  <p className="truncate text-[12px]" style={{ color: USER_INFO_COLORS.muted }}>
                    {tx.note || new Date(tx.createdAt).toLocaleString()}
                  </p>
                </div>
                <span
                  className="shrink-0 font-semibold"
                  style={{
                    color: tx.amount >= 0 ? "#15803d" : "#b91c1c",
                  }}
                >
                  {tx.amount >= 0 ? "+" : ""}
                  {formatUzs(tx.amount, language)}
                </span>
              </li>
            ))}
          </ul>
        )}
      </div>
    </section>
  );
}
