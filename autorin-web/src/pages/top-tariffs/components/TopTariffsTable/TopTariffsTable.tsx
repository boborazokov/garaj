import { Pencil, Trash2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { useLanguage } from "@/lib/i18n";
import { TOP_PLAN_LABELS, TOP_TARIFFS_TEXTS } from "../../constants";
import { formatUzs } from "../../helpers";
import type { TopTariffsTableProps } from "../../types";
import "./top-tariffs-table.css";

export function TopTariffsTable({
  rows,
  loading,
  busy,
  onEdit,
  onDelete,
}: TopTariffsTableProps) {
  const { t } = useLanguage();

  if (loading && rows.length === 0) {
    return (
      <p className="m-0 px-3.5 py-8 text-center text-[13px] text-muted-foreground">
        {t(TOP_TARIFFS_TEXTS.loading)}
      </p>
    );
  }

  if (!loading && rows.length === 0) {
    return (
      <p className="m-0 px-3.5 py-8 text-center text-[13px] text-muted-foreground">
        {t(TOP_TARIFFS_TEXTS.empty)}
      </p>
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="top-tariffs-table">
        <thead>
          <tr>
            <th>{t(TOP_TARIFFS_TEXTS.plan)}</th>
            <th>{t(TOP_TARIFFS_TEXTS.days)}</th>
            <th>{t(TOP_TARIFFS_TEXTS.discount)}</th>
            <th>{t(TOP_TARIFFS_TEXTS.price)}</th>
            <th>{t(TOP_TARIFFS_TEXTS.priority)}</th>
            <th>{t(TOP_TARIFFS_TEXTS.actions)}</th>
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={row.plan}>
              <td className="top-tariffs-table__plan">
                {t(TOP_PLAN_LABELS[row.plan])}
              </td>
              <td>{row.days}</td>
              <td>{row.discountPercent ? `${row.discountPercent}%` : "—"}</td>
              <td>{formatUzs(row.amount)}</td>
              <td>{row.priority}</td>
              <td>
                <div className="top-tariffs-table__actions">
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="h-8"
                    disabled={busy}
                    onClick={() => onEdit(row)}
                  >
                    <Pencil className="size-3.5" />
                    {t(TOP_TARIFFS_TEXTS.edit)}
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="h-8 border-red-200 bg-red-50 text-red-600 hover:bg-red-100 hover:text-red-700"
                    disabled={busy}
                    onClick={() => onDelete(row)}
                  >
                    <Trash2 className="size-3.5" />
                    {t(TOP_TARIFFS_TEXTS.delete)}
                  </Button>
                </div>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
