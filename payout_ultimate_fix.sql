
-- 1. Disable RLS temporarily to reset state
ALTER TABLE public.payout_accounts DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions DISABLE ROW LEVEL SECURITY;

-- 2. Drop EVERY potential conflicting policy
DROP POLICY IF EXISTS "Admins manage payout_accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Admin full access to all payout accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Admin_Full_Control_v1" ON public.payout_accounts;
DROP POLICY IF EXISTS "Admin_Global_Visibility" ON public.payout_accounts;
DROP POLICY IF EXISTS "Clients view own approved/rejected accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Client_Self_View_v1" ON public.payout_accounts;
DROP POLICY IF EXISTS "Client_Self_Isolation" ON public.payout_accounts;
DROP POLICY IF EXISTS "Client_Self_Submission" ON public.payout_accounts;

DROP POLICY IF EXISTS "Admins manage payout_transactions" ON public.payout_transactions;
DROP POLICY IF EXISTS "Admin_Tx_Full_Control_v1" ON public.payout_transactions;
DROP POLICY IF EXISTS "Admin_Global_Tx_Visibility" ON public.payout_transactions;
DROP POLICY IF EXISTS "Admin_Global_Tx_Visibility_v1" ON public.payout_transactions;
DROP POLICY IF EXISTS "Client_Tx_Self_View_v1" ON public.payout_transactions;
DROP POLICY IF EXISTS "Client_Tx_Isolation" ON public.payout_transactions;

-- 3. Update the is_admin function to be bulletproof
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    -- Direct email check from the authenticated JWT (Most reliable)
    (auth.jwt() ->> 'email' = 'admin@onestars.digital')
    OR
    -- Check if user is marked as admin in profiles
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = true)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. RE-ENABLE RLS with Global Admin Access
ALTER TABLE public.payout_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions ENABLE ROW LEVEL SECURITY;

-- 5. THE MASTER ADMIN POLICY (GRANT ALL)
CREATE POLICY "MASTER_ADMIN_UNRESTRICTED_ACCESS"
ON public.payout_accounts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

CREATE POLICY "MASTER_ADMIN_TX_UNRESTRICTED_ACCESS"
ON public.payout_transactions
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 6. CLIENT ISOLATION POLICY (STRICTLY THEIR OWN ONLY)
CREATE POLICY "CLIENT_RESTRICTED_ACCESS"
ON public.payout_accounts
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

CREATE POLICY "CLIENT_INSERT_ACCESS"
ON public.payout_accounts
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = client_id);

CREATE POLICY "CLIENT_TX_RESTRICTED_ACCESS"
ON public.payout_transactions
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

-- 7. Ensure real-time is fully enabled
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;
