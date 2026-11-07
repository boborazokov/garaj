import { useEffect, useRef, useState } from "react";
import { useMutation, useQuery } from "@apollo/client/react";
import { Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  CREATE_CATEGORY,
  DELETE_CATEGORY,
  GET_CATEGORIES,
  UPDATE_CATEGORY,
} from "@/graphql/operations";
import {
  categoryLabel,
  namesFromRow,
} from "@/lib/category-names";
import { useLanguage } from "@/lib/i18n";
import { mediaUrl } from "@/lib/media";
import { uploadCategoryIcon } from "@/lib/upload";
import type { CategoryRow, CategoryType } from "@/types";
import {
  CategoriesTable,
  CategoriesToolbar,
  CategoryFormDialog,
  ConfirmDialog,
} from "./components";
import { CATEGORIES_TEXTS } from "./constants";
import { emptyCategoryForm } from "./helpers";
import type { CategoryFormState } from "./types";

export function CategoriesPage() {
  const { t } = useLanguage();
  const [type, setType] = useState<CategoryType>("BRAND");
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [editing, setEditing] = useState<CategoryRow | null>(null);
  const [creating, setCreating] = useState(false);
  const [form, setForm] = useState<CategoryFormState>(emptyCategoryForm);
  const [iconFile, setIconFile] = useState<File | null>(null);
  const [iconPreview, setIconPreview] = useState<string | null>(null);
  const [uploading, setUploading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [pendingDelete, setPendingDelete] = useState<CategoryRow | null>(null);
  const fileInputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    const timer = window.setTimeout(() => setSearch(searchInput.trim()), 300);
    return () => window.clearTimeout(timer);
  }, [searchInput]);

  useEffect(() => {
    return () => {
      if (iconPreview?.startsWith("blob:")) {
        URL.revokeObjectURL(iconPreview);
      }
    };
  }, [iconPreview]);

  const { data, loading, refetch } = useQuery<{ getCategories: CategoryRow[] }>(
    GET_CATEGORIES,
    {
      fetchPolicy: "cache-and-network",
      variables: {
        filter: {
          type,
          ...(search ? { search } : {}),
        },
      },
    },
  );

  const [createCategory] = useMutation(CREATE_CATEGORY);
  const [updateCategory] = useMutation(UPDATE_CATEGORY);
  const [deleteCategory, { loading: deleting }] = useMutation(DELETE_CATEGORY);

  const rows = data?.getCategories ?? [];
  const modalOpen = creating || editing !== null;

  function clearIconPreview() {
    if (iconPreview?.startsWith("blob:")) {
      URL.revokeObjectURL(iconPreview);
    }
    setIconPreview(null);
    setIconFile(null);
    if (fileInputRef.current) fileInputRef.current.value = "";
  }

  function openCreate() {
    setCreating(true);
    setEditing(null);
    setForm(emptyCategoryForm());
    clearIconPreview();
    setError(null);
  }

  function openEdit(row: CategoryRow) {
    setEditing(row);
    setCreating(false);
    setForm({ names: namesFromRow(row) });
    clearIconPreview();
    setIconPreview(row.iconUrl ? mediaUrl(row.iconUrl) : null);
    setError(null);
  }

  function closeModal() {
    setCreating(false);
    setEditing(null);
    setForm(emptyCategoryForm());
    clearIconPreview();
    setError(null);
    setUploading(false);
  }

  function onPickIcon(file: File | undefined) {
    if (!file) return;
    if (!file.type.startsWith("image/")) {
      setError(t(CATEGORIES_TEXTS.errorImage));
      return;
    }
    clearIconPreview();
    setIconFile(file);
    setIconPreview(URL.createObjectURL(file));
    setError(null);
  }

  async function save() {
    setError(null);
    const { en, ru, uz } = form.names;
    if (!en.trim() || !ru.trim() || !uz.trim()) {
      setError(t(CATEGORIES_TEXTS.errorNames));
      return;
    }

    const hasIcon = iconFile != null || (editing?.iconUrl?.trim() ?? "").length > 0;
    if (!hasIcon) {
      setError(t(CATEGORIES_TEXTS.errorIcon));
      return;
    }

    setUploading(true);
    try {
      let iconUrl = editing?.iconUrl?.trim() || undefined;
      if (iconFile) {
        iconUrl = await uploadCategoryIcon(iconFile);
      }

      const dataPayload = {
        names: {
          en: en.trim(),
          ru: ru.trim(),
          uz: uz.trim(),
        },
        type,
        iconUrl,
      };

      if (editing) {
        await updateCategory({
          variables: { categoryId: editing._id, data: dataPayload },
        });
      } else {
        await createCategory({ variables: { data: dataPayload } });
      }
      closeModal();
      await refetch();
    } catch (e) {
      setError(e instanceof Error ? e.message : t(CATEGORIES_TEXTS.errorSave));
    } finally {
      setUploading(false);
    }
  }

  async function confirmDelete() {
    if (!pendingDelete) return;
    try {
      await deleteCategory({ variables: { categoryId: pendingDelete._id } });
      setPendingDelete(null);
      await refetch();
    } catch (e) {
      setPendingDelete(null);
      window.alert(e instanceof Error ? e.message : t(CATEGORIES_TEXTS.errorDelete));
    }
  }

  return (
    <div className="flex flex-col gap-2.5">
      <div className="flex items-start justify-between gap-3">
        <div className="min-w-0">
          <h1 className="m-0 text-[20px] font-semibold leading-tight text-foreground">
            {t(CATEGORIES_TEXTS.title)}
          </h1>
          <p className="mt-1 mb-0 text-[13px] text-muted-foreground">
            {t(CATEGORIES_TEXTS.subtitle)}
          </p>
        </div>
        <Button type="button" className="h-9 shrink-0" onClick={openCreate}>
          <Plus className="size-4" />
          {t(CATEGORIES_TEXTS.add)}
        </Button>
      </div>

      <section className="overflow-hidden rounded-[10px] border border-border bg-card">
        <CategoriesToolbar
          search={searchInput}
          type={type}
          onSearchChange={setSearchInput}
          onTypeChange={(next) => {
            setType(next);
            setSearchInput("");
            setSearch("");
          }}
        />

        <CategoriesTable
          rows={rows}
          loading={loading}
          onEdit={openEdit}
          onDelete={setPendingDelete}
        />
      </section>

      <CategoryFormDialog
        open={modalOpen}
        editing={editing}
        type={type}
        form={form}
        iconPreview={iconPreview}
        error={error}
        busy={uploading}
        fileInputRef={fileInputRef}
        onClose={closeModal}
        onFormChange={setForm}
        onPickIcon={onPickIcon}
        onClearIcon={clearIconPreview}
        onSave={() => {
          void save();
        }}
      />

      <ConfirmDialog
        open={Boolean(pendingDelete)}
        title={t(CATEGORIES_TEXTS.confirmDeleteTitle)}
        message={
          pendingDelete
            ? `${categoryLabel(pendingDelete)}. ${t(CATEGORIES_TEXTS.confirmDelete)}`
            : t(CATEGORIES_TEXTS.confirmDelete)
        }
        confirmLabel={t(CATEGORIES_TEXTS.delete)}
        busy={deleting}
        onCancel={() => setPendingDelete(null)}
        onConfirm={() => {
          void confirmDelete();
        }}
      />
    </div>
  );
}
