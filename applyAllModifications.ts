
import { supabase } from "./supabase";

export type MarketAssetRow = {
  id?: string | number;
  asset_name: string;
  price_mmk: number;
  description?: string;
  platform?: string;
  status?: string;
  profile_link?: string;
  image_url?: string;
};

/**
 * Standard Database Upsert Operation
 * Synchronizes frontend mutations with Supabase market_assets table.
 */
export async function applyAllModifications(mutations: MarketAssetRow[]) {
  if (!mutations.length) return { ok: true };

  const payload = mutations.map(m => ({
    ...m,
    updated_at: new Date().toISOString()
  }));

  const { data, error } = await supabase
    .from("market_assets")
    .upsert(payload, { onConflict: "id" })
    .select("*");

  if (error) {
    console.error("[Database] Sync Error:", error.message);
    return { ok: false, message: error.message };
  }

  return { ok: true, data };
}
