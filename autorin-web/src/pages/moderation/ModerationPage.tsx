import { useEffect, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import {
  APPROVE_PART,
  GET_PENDING_PARTS,
  REJECT_PART,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import type { PaginatedParts, Part } from "@/types";
import {
  ApproveDialog,
  ModerationDetailDialog,
  ModerationPagination,
  ModerationTable,
  ModerationToolbar,
  RejectDialog,
} from "./components";
import { MODERATION_PAGE_SIZE, MODERATION_TEXTS } from "./constants";

export function ModerationPage() {
  const { t } = useLanguage();
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [detailPart, setDetailPart] = useState<Part | null>(null);
  const [pendingApprove, setPendingApprove] = useState<Part | null>(null);
  const [pendingReject, setPendingReject] = useState<Part | null>(null);
  const [rejectNote, setRejectNote] = useState("");
  const [busyId, setBusyId] = useState<string | null>(null);

  useEffect(() => {
    const timer = window.setTimeout(() => setSearch(searchInput.trim()), 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    setPage(1);
  }, [search]);

  const { data, loading, refetch } = useQuery<{ getPendingParts: PaginatedParts }>(
    GET_PENDING_PARTS,
    {
      fetchPolicy: "cache-and-network",
      variables: {
        pagination: { page, limit: MODERATION_PAGE_SIZE },
        search: search || undefined,
      },
    },
  );

  const [approvePart, { loading: approving }] = useMutation(APPROVE_PART);
  const [rejectPart, { loading: rejecting }] = useMutation(REJECT_PART);

  const result = data?.getPendingParts;
  const rows = result?.payload ?? [];
  const canClear = Boolean(searchInput.trim());

  async function confirmApprove() {
    if (!pendingApprove) return;
    const part = pendingApprove;
    setBusyId(part._id);
    try {
      await approvePart({ variables: { partId: part._id } });
      setPendingApprove(null);
      await refetch();
    } catch {
      window.alert(t(MODERATION_TEXTS.approveFailed));
    } finally {
      setBusyId(null);
    }
  }

  async function confirmReject() {
    if (!pendingReject) return;
    const note = rejectNote.trim();
    if (!note) {
      window.alert(t(MODERATION_TEXTS.noteRequired));
      return;
    }
    const part = pendingReject;
    setBusyId(part._id);
    try {
      await rejectPart({ variables: { partId: part._id, note } });
      setPendingReject(null);
      setRejectNote("");
      await refetch();
    } catch {
      window.alert(t(MODERATION_TEXTS.rejectFailed));
    } finally {
      setBusyId(null);
    }
  }

  function clearFilters() {
    setSearchInput("");
    setSearch("");
  }

  return (
    <div className="flex flex-col gap-2.5">
      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <ModerationToolbar
          search={searchInput}
          canClear={canClear}
          onSearchChange={setSearchInput}
          onClear={clearFilters}
        />

        <ModerationTable
          rows={rows}
          loading={loading}
          busyId={busyId}
          onOpen={setDetailPart}
          onApprove={(part) => {
            setDetailPart(null);
            setPendingApprove(part);
          }}
          onReject={(part) => {
            setDetailPart(null);
            setRejectNote("");
            setPendingReject(part);
          }}
        />

        <ModerationPagination
          page={result?.page ?? page}
          totalPages={result?.totalPages ?? 1}
          onPage={setPage}
        />
      </section>

      <ModerationDetailDialog
        open={Boolean(detailPart)}
        part={detailPart}
        onClose={() => setDetailPart(null)}
        onApprove={(part) => {
          setDetailPart(null);
          setPendingApprove(part);
        }}
        onReject={(part) => {
          setDetailPart(null);
          setRejectNote("");
          setPendingReject(part);
        }}
      />

      <ApproveDialog
        open={Boolean(pendingApprove)}
        partName={pendingApprove?.name ?? ""}
        busy={approving}
        onCancel={() => setPendingApprove(null)}
        onConfirm={() => {
          void confirmApprove();
        }}
      />

      <RejectDialog
        open={Boolean(pendingReject)}
        partName={pendingReject?.name ?? ""}
        note={rejectNote}
        busy={rejecting}
        onNoteChange={setRejectNote}
        onCancel={() => {
          setPendingReject(null);
          setRejectNote("");
        }}
        onConfirm={() => {
          void confirmReject();
        }}
      />
    </div>
  );
}
