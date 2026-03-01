
-- 1. Reset everything to be sure
ALTER TABLE public.payout_accounts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions DISABLE ROW LEVEL SECURITY;

-- 2. Drop all old policies
DROP POLICY IF EXISTS "MASTER_ADMIN_UNRESTRICTED_ACCESS" ON public.payout_accounts;
DROP POLICY IF EXISTS "MASTER_ADMIN_TX_UNRESTRICTED_ACCESS" ON public.payout_transactions;
DROP POLICY IF EXISTS "Admin_Global_Visibility" ON public.payout_accounts;
DROP POLICY IF EXISTS "Admin_Global_Tx_Visibility" ON public.payout_transactions;
DROP POLICY IF EXISTS "CLIENT_RESTRICTED_ACCESS" ON public.payout_accounts;
DROP POLICY IF EXISTS "CLIENT_TX_RESTRICTED_ACCESS" ON public.payout_transactions;

-- 3. Robust is_admin function (Email is the key)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    (auth.jwt() ->> 'email' = 'admin@onestars.digital')
    OR
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. Enable RLS back
ALTER TABLE public.payout_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions ENABLE ROW LEVEL SECURITY;

-- 5. ADMIN POLICY: အကန့်အသတ်မရှိ မြင်ရမယ်၊ ပြင်ရမယ်
CREATE POLICY "ADMIN_FULL_ACCESS_V3"
ON public.payout_accounts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "ADMIN_TX_FULL_ACCESS_V3"
ON public.payout_transactions
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 6. CLIENT POLICY: ကိုယ့် data ကိုယ်ပဲ မြင်ရမယ် (Client offline ဖြစ်နေလည်း DB ထဲမှာ ရှိနေမှာဖြစ်ပြီး Admin က မြင်ရပါမယ်)
CREATE POLICY "CLIENT_VIEW_OWN_V3"
ON public.payout_accounts
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

CREATE POLICY "CLIENT_INSERT_OWN_V3"
ON public.payout_accounts
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = client_id);

CREATE POLICY "CLIENT_TX_VIEW_OWN_V3"
ON public.payout_transactions
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

-- 7. Realtime Enable
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;
