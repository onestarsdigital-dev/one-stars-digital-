
-- 1. Grant DELETE permission on transactions for Admins
DROP POLICY IF EXISTS "Admins can delete transactions" ON public.payout_transactions;
CREATE POLICY "Admins can delete transactions"
ON public.payout_transactions
FOR DELETE
TO authenticated
USING (public.is_admin());

-- 2. Grant DELETE permission on accounts for Admins (in case needed)
DROP POLICY IF EXISTS "Admins can delete accounts" ON public.payout_accounts;
CREATE POLICY "Admins can delete accounts"
ON public.payout_accounts
FOR DELETE
TO authenticated
USING (public.is_admin());

-- 3. Ensure the is_admin function is up to date and reliable
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
