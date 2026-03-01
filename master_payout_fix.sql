
-- 1. Reset all Row Level Security policies to start fresh
DROP POLICY IF EXISTS "SUPER_ADMIN_ACCOUNTS_POLICY" ON public.payout_accounts;
DROP POLICY IF EXISTS "SUPER_ADMIN_TX_POLICY" ON public.payout_transactions;

-- 2. Bulletproof is_admin check (Centralized Logic)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    -- Direct email check from the authenticated JWT (Most reliable and prevents recursion)
    (auth.jwt() ->> 'email' = 'admin@onestars.digital')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Enable RLS and Grant ALL permissions to Admin
ALTER TABLE public.payout_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions ENABLE ROW LEVEL SECURITY;

-- Global Admin Policy for Accounts
CREATE POLICY "SUPER_ADMIN_ACCOUNTS_POLICY"
ON public.payout_accounts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Global Admin Policy for Transactions
CREATE POLICY "SUPER_ADMIN_TX_POLICY"
ON public.payout_transactions
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 4. Standard Client Policies (Clients can only see their own)
DROP POLICY IF EXISTS "CLIENT_SELECT_OWN_ACCS" ON public.payout_accounts;
DROP POLICY IF EXISTS "CLIENT_INSERT_OWN_ACCS" ON public.payout_accounts;
DROP POLICY IF EXISTS "CLIENT_SELECT_OWN_TXS" ON public.payout_transactions;

CREATE POLICY "CLIENT_SELECT_OWN_ACCS" ON public.payout_accounts FOR SELECT TO authenticated USING (auth.uid() = client_id);
CREATE POLICY "CLIENT_INSERT_OWN_ACCS" ON public.payout_accounts FOR INSERT TO authenticated WITH CHECK (auth.uid() = client_id);
CREATE POLICY "CLIENT_SELECT_OWN_TXS" ON public.payout_transactions FOR SELECT TO authenticated USING (auth.uid() = client_id);

-- 5. Ensure Realtime is active
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;
