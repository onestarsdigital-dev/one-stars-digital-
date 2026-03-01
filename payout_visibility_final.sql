
-- 1. Create a super-robust admin check function
-- This checks for the hardcoded admin email first to guarantee access
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    -- Check 1: Hardcoded email check from JWT (Absolute Power)
    (auth.jwt() ->> 'email' = 'admin@onestars.digital')
    OR
    -- Check 2: User exists in profiles and marked as admin
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Clear all existing restrictive policies to avoid conflicts
DROP POLICY IF EXISTS "Admins manage payout_accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Admin full access to all payout accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Admin_Full_Control_v1" ON public.payout_accounts;
DROP POLICY IF EXISTS "Clients view own approved/rejected accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Client_Self_View_v1" ON public.payout_accounts;

-- 3. Create absolute Admin Policy (Admin sees EVERYTHING)
CREATE POLICY "Admin_Global_Visibility"
ON public.payout_accounts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 4. Create standard Client Policy (Clients only see THEIR OWN data)
-- This ensures that when a client is offline, their data remains in the DB for the Admin
CREATE POLICY "Client_Self_Isolation"
ON public.payout_accounts
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

CREATE POLICY "Client_Self_Submission"
ON public.payout_accounts
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = client_id);

-- 5. Repeat for Transactions to ensure ledger is visible
DROP POLICY IF EXISTS "Admin_Tx_Full_Control_v1" ON public.payout_transactions;
DROP POLICY IF EXISTS "Client_Tx_Self_View_v1" ON public.payout_transactions;

CREATE POLICY "Admin_Global_Tx_Visibility"
ON public.payout_transactions
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "Client_Tx_Isolation"
ON public.payout_transactions
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

-- 6. Important: Ensure these tables have Realtime enabled
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;
