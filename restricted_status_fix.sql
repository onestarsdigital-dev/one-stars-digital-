
-- 1. Remove old status constraint if it exists
ALTER TABLE public.payout_accounts 
DROP CONSTRAINT IF EXISTS payout_accounts_status_check;

-- 2. Add a new constraint that includes 'restricted' and ensure 'paid' is supported
ALTER TABLE public.payout_accounts 
ADD CONSTRAINT payout_accounts_status_check 
CHECK (status IN ('pending', 'approved', 'rejected', 'paid', 'restricted'));

-- 3. Ensure RLS is active
ALTER TABLE public.payout_accounts ENABLE ROW LEVEL SECURITY;
