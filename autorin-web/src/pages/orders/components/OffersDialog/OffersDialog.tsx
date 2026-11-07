import { useQuery } from "@apollo/client/react";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Skeleton } from "@/components/ui/skeleton";
import { Badge } from "@/components/ui/badge";
import { GET_ORDER_RESPONSES } from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { OrderOfferRow } from "@/types";
import { ORDERS_TEXTS } from "../../constants";
import { formatBudget, formatDate } from "../../helpers";
import type { OffersDialogProps } from "../../types";

export function OffersDialog({ order, open, onClose }: OffersDialogProps) {
  const { t, language } = useLanguage();
  const { data, loading } = useQuery<{ getOrderResponses: OrderOfferRow[] }>(
    GET_ORDER_RESPONSES,
    {
      skip: !open || !order?._id,
      fetchPolicy: "network-only",
      variables: { orderId: order?._id },
    },
  );

  const offers = data?.getOrderResponses ?? [];

  return (
    <Dialog
      open={open}
      onOpenChange={(next) => {
        if (!next) onClose();
      }}
    >
      <DialogContent className="sm:max-w-[440px]">
        <DialogHeader>
          <DialogTitle>{t(ORDERS_TEXTS.offersTitle)}</DialogTitle>
          {order?.title ? (
            <p className="m-0 truncate text-[13px] text-muted-foreground">{order.title}</p>
          ) : null}
        </DialogHeader>

        <div className="grid max-h-[360px] gap-2 overflow-y-auto pr-0.5">
          {loading && offers.length === 0
            ? Array.from({ length: 3 }, (_, index) => (
                <div
                  key={`offer-skeleton-${index}`}
                  className="rounded-[8px] border border-border px-3 py-2.5"
                >
                  <Skeleton className="mb-2 h-3.5 w-28" />
                  <Skeleton className="mb-1.5 h-3 w-full" />
                  <Skeleton className="h-3 w-20" />
                </div>
              ))
            : null}

          {!loading && offers.length === 0 ? (
            <p className="m-0 py-6 text-center text-[13px] text-muted-foreground">
              {t(ORDERS_TEXTS.offersEmpty)}
            </p>
          ) : null}

          {offers.map((offer) => (
            <div
              key={offer._id}
              className="rounded-[8px] border border-border bg-slate-50/80 px-3 py-2.5"
            >
              <div className="flex items-start justify-between gap-2">
                <div className="min-w-0">
                  <div className="truncate text-[13px] font-medium text-foreground">
                    {offer.seller?.name?.trim() || "—"}
                  </div>
                  {offer.seller?.phone ? (
                    <div className="mt-0.5 text-[11px] text-muted-foreground">
                      {offer.seller.phone}
                    </div>
                  ) : null}
                </div>
                {offer.isAccepted ? (
                  <Badge variant="success" className="shrink-0">
                    {t(ORDERS_TEXTS.accepted)}
                  </Badge>
                ) : null}
              </div>

              <p className="mt-2 mb-0 text-[13px] leading-snug text-slate-700">{offer.text}</p>

              <div className="mt-2 flex flex-wrap gap-x-3 gap-y-1 text-[12px] text-muted-foreground">
                <span>
                  {t(ORDERS_TEXTS.offerPrice)}:{" "}
                  <span className="font-medium text-foreground">
                    {formatBudget(
                      offer.offeredPrice ?? undefined,
                      offer.part?.currency,
                      language,
                      t(ORDERS_TEXTS.negotiable),
                    )}
                  </span>
                </span>
                {offer.deliveryDays != null ? (
                  <span>
                    {t(ORDERS_TEXTS.deliveryDays)}:{" "}
                    <span className="font-medium text-foreground">
                      {offer.deliveryDays} {t(ORDERS_TEXTS.daysShort)}
                    </span>
                  </span>
                ) : null}
                <span>{formatDate(offer.createdAt, language)}</span>
              </div>
            </div>
          ))}
        </div>

        <DialogFooter>
          <Button type="button" variant="outline" onClick={onClose}>
            {t(ORDERS_TEXTS.close)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
