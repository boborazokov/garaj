import { emptyCategoryNames } from "@/lib/category-names";
import type { CategoryFormState } from "./types";

export function emptyCategoryForm(): CategoryFormState {
  return { names: emptyCategoryNames() };
}
