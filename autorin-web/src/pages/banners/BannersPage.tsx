import { useEffect, useRef, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  ADMIN_LIST_ADVERTISEMENTS,
  CREATE_ADVERTISEMENT,
  DELETE_ADVERTISEMENT,
  UPDATE_ADVERTISEMENT,
} from "@/graphql/operations";
import { useLanguage } from "@/lib/i18n";
import { mediaUrl } from "@/lib/media";
import { uploadAdvertisementBanner } from "@/lib/upload";
import type {
  AdvertisementRow,
  AdvertisementStatus,
  CategoryType,
  PaginatedAdvertisements,
} from "@/types";
import {
  BannerFormDialog,
  BannersPagination,
  BannersTable,
  BannersToolbar,
  ConfirmDialog,
  StatsDialog,
} from "./components";
import { BANNERS_TEXTS } from "./constants";
import {
  dateInputToIso,
  emptyBannerForm,
  endDateInputToIso,
  inferDuration,
  isValidBannerLink,
  toDateInputValue,
  writableStatus,
} from "./helpers";
import type { BannerFormState } from "./types";

const PAGE_SIZE = 12;

export function BannersPage() {
  const { t } = useLanguage();
  const [placement, setPlacement] = useState<CategoryType>("BRAND");
  const [status, setStatus] = useState<"" | AdvertisementStatus>("");
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [page, setPage] = useState(1);
  const [editing, setEditing] = useState<AdvertisementRow | null>(null);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState<BannerFormState>(emptyBannerForm);
  const [imageFile, setImageFile] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pendingDelete, setPendingDelete] = useState<AdvertisementRow | null>(null);
  const [statsBanner, setStatsBanner] = useState<AdvertisementRow | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const canClear = Boolean(searchInput || status);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      setSearch(searchInput.trim());
      setPage(1);
    }, 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    return () => {
      if (imagePreview?.startsWith("blob:")) {
        URL.revokeObjectURL(imagePreview);
      }
    };
  }, [imagePreview]);

  const { data, loading, refetch } = useQuery<{
    adminListAdvertisements: PaginatedAdvertisements;
  }>(ADMIN_LIST_ADVERTISEMENTS, {
    fetchPolicy: "cache-and-network",
    variables: {
      pagination: { page, limit: PAGE_SIZE },
      filter: {
        type: placement,
        ...(search ? { title: search } : {}),
        ...(status ? { status } : {}),
      },
    },
  });

  const [createAd] = useMutation(CREATE_ADVERTISEMENT);
  const [updateAd] = useMutation(UPDATE_ADVERTISEMENT);
  const [deleteAd, { loading: deleting }] = useMutation(DELETE_ADVERTISEMENT);

  const result = data?.adminListAdvertisements;
  const rows = result?.payload ?? [];
  const modalOpen = creating || editing !== null;

  function clearImagePreview() {
    if (imagePreview?.startsWith("blob:")) {
      URL.revokeObjectURL(imagePreview);
    }
    setImagePreview(null);
    setImageFile(null);
    if (fileInputRef.current) fileInputRef.current.value = "";
  }

  function openCreate() {
    setCreating(true);
    setEditing(null);
    setForm(emptyBannerForm());
    clearImagePreview();
    setError(null);
  }

  function openEdit(row: AdvertisementRow) {
    setEditing(row);
    setCreating(false);
    setForm({
      title: row.title,
      link: row.link,
      bannerImageUrl: row.bannerImageUrl,
      startsAt: toDateInputValue(row.startsAt),
      endsAt: toDateInputValue(row.endsAt),
      duration: inferDuration(
        toDateInputValue(row.startsAt),
        toDateInputValue(row.endsAt),
      ),
      status: writableStatus(row.status),
    });
    clearImagePreview();
    setImagePreview(row.bannerImageUrl ? mediaUrl(row.bannerImageUrl) : null);
    setError(null);
  }

  function closeModal() {
    setCreating(false);
    setEditing(null);
    setForm(emptyBannerForm());
    clearImagePreview();
    setError(null);
    setUploading(false);
  }

  function onPickImage(file: File | undefined) {
    if (!file) return;
    if (!file.type.startsWith("image/")) {
      setError(t(BANNERS_TEXTS.errorImage));
      return;
    }
    clearImagePreview();
    setImageFile(file);
    setImagePreview(URL.createObjectURL(file));
    setError(null);
  }

  function onClearImage() {
    clearImagePreview();
    setForm((prev) => ({ ...prev, bannerImageUrl: "" }));
  }

  async function save() {
    setError(null);
    if (!form.title.trim() || !form.link.trim()) {
      setError(t(BANNERS_TEXTS.errorRequired));
      return;
    }
    if (!isValidBannerLink(form.link)) {
      setError(t(BANNERS_TEXTS.errorLink));
      return;
    }

    const hasImage =
      imageFile != null || (form.bannerImageUrl.trim() || editing?.bannerImageUrl?.trim() || "").length > 0;
    if (!hasImage) {
      setError(t(BANNERS_TEXTS.errorImage));
      return;
    }

    if (form.startsAt && form.endsAt && form.startsAt > form.endsAt) {
      setError(t(BANNERS_TEXTS.errorDates));
      return;
    }

    setUploading(true);
    try {
      let bannerImageUrl = form.bannerImageUrl.trim() || editing?.bannerImageUrl?.trim() || "";
      if (imageFile) {
        bannerImageUrl = await uploadAdvertisementBanner(imageFile);
      }

      const dataPayload = {
        type: placement,
        title: form.title.trim(),
        link: form.link.trim(),
        bannerImageUrl,
        startsAt: dateInputToIso(form.startsAt),
        endsAt: endDateInputToIso(form.endsAt),
        status: form.status,
      };

      if (editing) {
        await updateAd({
          variables: { advertisementId: editing._id, data: dataPayload },
        });
      } else {
        await createAd({ variables: { data: dataPayload } });
      }
      closeModal();
      await refetch();
    } catch (e) {
      setError(e instanceof Error ? e.message : t(BANNERS_TEXTS.errorSave));
    } finally {
      setUploading(false);
    }
  }

  async function confirmDelete() {
    if (!pendingDelete) return;
    try {
      await deleteAd({ variables: { advertisementId: pendingDelete._id } });
      setPendingDelete(null);
      await refetch();
    } catch (e) {
      setPendingDelete(null);
      window.alert(e instanceof Error ? e.message : t(BANNERS_TEXTS.errorDelete));
    }
  }

  return (
    <div className="flex flex-col gap-2.5">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <h1 className="m-0 text-[20px] font-semibold leading-tight text-foreground">
            {t(BANNERS_TEXTS.title)}
          </h1>
          <p className="mt-1 mb-0 text-[13px] text-muted-foreground">
            {t(BANNERS_TEXTS.subtitle)}
          </p>
        </div>
        <Button type="button" className="h-9 shrink-0" onClick={openCreate}>
          <Plus className="size-4" />
          {t(BANNERS_TEXTS.add)}
        </Button>
      </div>

      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <BannersToolbar
          search={searchInput}
          placement={placement}
          status={status}
          canClear={canClear}
          onSearchChange={setSearchInput}
          onPlacementChange={(next) => {
            setPlacement(next);
            setPage(1);
          }}
          onStatusChange={(next) => {
            setStatus(next);
            setPage(1);
          }}
          onClear={() => {
            setSearchInput("");
            setSearch("");
            setStatus("");
            setPage(1);
          }}
        />

        <BannersTable
          rows={rows}
          loading={loading}
          onEdit={openEdit}
          onDelete={setPendingDelete}
          onStats={setStatsBanner}
        />

        <BannersPagination
          page={page}
          totalPages={result?.totalPages ?? 1}
          onPage={setPage}
        />
      </section>

      <BannerFormDialog
        open={modalOpen}
        editing={editing}
        placement={placement}
        form={form}
        imagePreview={imagePreview}
        error={error}
        busy={uploading}
        fileInputRef={fileInputRef}
        onClose={closeModal}
        onFormChange={setForm}
        onPickImage={onPickImage}
        onClearImage={onClearImage}
        onSave={() => {
          void save();
        }}
      />

      <StatsDialog
        banner={statsBanner}
        open={Boolean(statsBanner)}
        onClose={() => setStatsBanner(null)}
      />

      <ConfirmDialog
        open={Boolean(pendingDelete)}
        title={t(BANNERS_TEXTS.confirmDeleteTitle)}
        message={
          pendingDelete
            ? `${pendingDelete.title}. ${t(BANNERS_TEXTS.confirmDelete)}`
            : t(BANNERS_TEXTS.confirmDelete)
        }
        confirmLabel={t(BANNERS_TEXTS.delete)}
        busy={deleting}
        onCancel={() => setPendingDelete(null)}
        onConfirm={() => {
          void confirmDelete();
        }}
      />
    </div>
  );
}
