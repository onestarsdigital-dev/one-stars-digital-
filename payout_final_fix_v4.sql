
-- 1. Fix constraints on payout_accounts
ALTER TABLE public.payout_accounts 
DROP CONSTRAINT IF EXISTS payout_accounts_bank_type_check;

ALTER TABLE public.payout_accounts 
ADD CONSTRAINT payout_accounts_bank_type_check 
CHECK (bank_type IN (
  'KBZ Pay', 
  'Wave Pay', 
  'KBZ Bank', 
  'AYA Bank', 
  'CB Bank', 
  'Thai Bank', 
  'Binance (USDT)',
  'Wave Money',
  'AYA Pay',
  'CB Pay',
  'USDT (Binance)'
));

ALTER TABLE public.payout_accounts 
DROP CONSTRAINT IF EXISTS payout_accounts_status_check;

ALTER TABLE public.payout_accounts 
ADD CONSTRAINT payout_accounts_status_check 
CHECK (status IN ('pending', 'approved', 'verified', 'rejected', 'paid'));

-- 2. Ensure RLS is enabled
ALTER TABLE public.payout_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions ENABLE ROW LEVEL SECURITY;

-- 3. Drop all old policies to start fresh
DROP POLICY IF EXISTS "ADMIN_GLOBAL_ACCESS_FINAL" ON public.payout_accounts;
DROP POLICY IF EXISTS "ADMIN_TX_GLOBAL_ACCESS_FINAL" ON public.payout_transactions;
DROP POLICY IF EXISTS "CLIENT_SELF_VIEW_FINAL" ON public.payout_accounts;
DROP POLICY IF EXISTS "CLIENT_SELF_TX_VIEW_FINAL" ON public.payout_transactions;
DROP POLICY IF EXISTS "Clients insert pending requests" ON public.payout_accounts;
DROP POLICY IF EXISTS "Clients view own approved/rejected accounts" ON public.payout_accounts;
DROP POLICY IF EXISTS "Clients view own transactions" ON public.payout_transactions;
DROP POLICY IF EXISTS "CLIENT_INSERT_OWN_ACCS" ON public.payout_accounts;
DROP POLICY IF EXISTS "CLIENT_INSERT_OWN_V3" ON public.payout_accounts;
DROP POLICY IF EXISTS "CLIENT_UPDATE_OWN_ACCS" ON public.payout_accounts;

-- 4. Admin Policies (Global Access)
CREATE POLICY "ADMIN_ALL_ACCESS" 
ON public.payout_accounts 
FOR ALL 
TO authenticated 
USING (public.is_admin()) 
WITH CHECK (public.is_admin());

CREATE POLICY "ADMIN_TX_ALL_ACCESS" 
ON public.payout_transactions 
FOR ALL 
TO authenticated 
USING (public.is_admin()) 
WITH CHECK (public.is_admin());

-- 5. Client Policies (Self Access)
CREATE POLICY "CLIENT_SELECT_OWN" 
ON public.payout_accounts 
FOR SELECT 
TO authenticated 
USING (auth.uid() = client_id);

CREATE POLICY "CLIENT_INSERT_OWN" 
ON public.payout_accounts 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = client_id);

CREATE POLICY "CLIENT_UPDATE_OWN" 
ON public.payout_accounts 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = client_id)
WITH CHECK (auth.uid() = client_id);

CREATE POLICY "CLIENT_TX_SELECT_OWN" 
ON public.payout_transactions 
FOR SELECT 
TO authenticated 
USING (auth.uid() = client_id);

-- 6. Realtime
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;
