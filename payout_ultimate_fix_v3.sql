
-- ၁။ Admin Check Function ကို အားအကောင်းဆုံးဖြစ်အောင် ပြင်မယ်
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    -- Auth JWT ထဲက email ကို တိုက်ရိုက်စစ်တာက အသေချာဆုံးပါ
    (auth.jwt() ->> 'email' = 'admin@onestars.digital')
    OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ၂။ RESTRICTIVE POLICIES တွေ အကုန်ဖြုတ်ချမယ်
DROP POLICY IF EXISTS "MASTER_ADMIN_UNRESTRICTED_ACCESS" ON public.payout_accounts;
DROP POLICY IF EXISTS "MASTER_ADMIN_TX_UNRESTRICTED_ACCESS" ON public.payout_transactions;
DROP POLICY IF EXISTS "ADMIN_FULL_ACCESS_V3" ON public.payout_accounts;
DROP POLICY IF EXISTS "ADMIN_TX_FULL_ACCESS_V3" ON public.payout_transactions;

-- ၃။ ADMIN ကို အကန့်အသတ်မရှိ (Global) မြင်ခွင့်ပေးမယ်
-- ဒါက Client တွေ Offline ဖြစ်နေလည်း Admin ဘက်က အကုန်မြင်ရမှာဖြစ်ပါတယ်
CREATE POLICY "ADMIN_GLOBAL_ACCESS_FINAL"
ON public.payout_accounts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "ADMIN_TX_GLOBAL_ACCESS_FINAL"
ON public.payout_transactions
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- ၄။ CLIENT အတွက်ကတော့ သူပိုင်တဲ့ data ပဲ သူမြင်ရမယ်
CREATE POLICY "CLIENT_SELF_VIEW_FINAL"
ON public.payout_accounts
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

CREATE POLICY "CLIENT_SELF_TX_VIEW_FINAL"
ON public.payout_transactions
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

-- ၅။ Realtime ကို အမြဲ On ထားမယ်
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;
