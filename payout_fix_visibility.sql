
-- 1. Ensure the admin check function is robust
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if the current user exists in profiles and is marked as admin
  -- OR check if the email matches the master admin email
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Update Payout Accounts Policies
DROP POLICY IF EXISTS "Admins manage payout_accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Admins can manage payout accounts" ON public.payout_accounts;

-- Grant Admins absolute power over all rows
CREATE POLICY "Admin full access to all payout accounts"
ON public.payout_accounts
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 3. Update Payout Transactions Policies
DROP POLICY IF EXISTS "Admins manage payout_transactions" ON public.payout_transactions;

-- Grant Admins absolute power over all transactions
CREATE POLICY "Admin full access to all payout transactions"
ON public.payout_transactions
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 4. Enable Realtime for these tables to ensure Admin sees updates immediately
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;

-- 5. Force a profile entry for the Admin if it doesn't exist
-- Replace the UUID with your actual Admin UUID from Auth users if known, 
-- or this will trigger on next manual login.
