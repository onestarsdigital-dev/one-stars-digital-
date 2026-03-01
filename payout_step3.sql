
-- 1. Helper function for admin check (if not already exists)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Add audit and rejection columns to payout_accounts
ALTER TABLE public.payout_accounts 
ADD COLUMN IF NOT EXISTS approved_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS approved_by UUID REFERENCES auth.users(id),
ADD COLUMN IF NOT EXISTS rejected_reason TEXT;

-- 3. Update status constraint to include 'rejected'
ALTER TABLE public.payout_accounts 
DROP CONSTRAINT IF EXISTS payout_accounts_status_check;

ALTER TABLE public.payout_accounts 
ADD CONSTRAINT payout_accounts_status_check 
CHECK (status IN ('pending', 'verified', 'rejected', 'paid'));

-- 4. Enable RLS
ALTER TABLE public.payout_accounts ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for payout_accounts
-- Admins: Full control
DROP POLICY IF EXISTS "Admins can manage payout accounts" ON public.payout_accounts;
CREATE POLICY "Admins can manage payout accounts"
ON public.payout_accounts
FOR ALL
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Clients: View own
DROP POLICY IF EXISTS "Clients can view own payout accounts" ON public.payout_accounts;
CREATE POLICY "Clients can view own payout accounts"
ON public.payout_accounts
FOR SELECT
USING (auth.uid() = client_id);

-- Clients: Insert only for self and as pending
DROP POLICY IF EXISTS "Clients can request payout account" ON public.payout_accounts;
CREATE POLICY "Clients can request payout account"
ON public.payout_accounts
FOR INSERT
WITH CHECK (
  auth.uid() = client_id 
  AND status = 'pending'
);

-- 6. Ensure Replica Identity for Realtime
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
