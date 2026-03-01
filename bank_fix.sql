
-- 1. Remove old bank_type constraint if it exists
ALTER TABLE public.payout_accounts 
DROP CONSTRAINT IF EXISTS payout_accounts_bank_type_check;

-- 2. Add a new, broader constraint that includes common types
ALTER TABLE public.payout_accounts 
ADD CONSTRAINT payout_accounts_bank_type_check 
CHECK (bank_type IN (
  'KBZ Pay', 
  'Wave Money', 
  'Binance (USDT)', 
  'Thai Bank', 
  'AYA Pay', 
  'CB Pay',
  'KBZ',
  'Wave',
  'USDT',
  'Thai'
));

-- 3. Ensure status check also allows 'verified' and 'paid'
ALTER TABLE public.payout_accounts 
DROP CONSTRAINT IF EXISTS payout_accounts_status_check;

ALTER TABLE public.payout_accounts 
ADD CONSTRAINT payout_accounts_status_check 
CHECK (status IN ('pending', 'approved', 'verified', 'rejected', 'paid'));
