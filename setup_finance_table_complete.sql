
-- 1. Create the table if it is completely missing
CREATE TABLE IF NOT EXISTS public.finance_records (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_name TEXT NOT NULL,
  buyer_name TEXT,
  account_link TEXT,
  platform TEXT,
  service_type TEXT,
  invoice_id TEXT UNIQUE,
  amount_usd NUMERIC(15,2) DEFAULT 0,
  amount_mmk NUMERIC(15,2) DEFAULT 0,
  amount_thb NUMERIC(15,2) DEFAULT 0,
  status TEXT DEFAULT 'Pending',
  payout_method TEXT,
  payout_date DATE DEFAULT CURRENT_DATE,
  record_type TEXT DEFAULT 'Income',
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Add missing columns just in case the table existed but was old
ALTER TABLE public.finance_records ADD COLUMN IF NOT EXISTS account_link TEXT;
ALTER TABLE public.finance_records ADD COLUMN IF NOT EXISTS buyer_name TEXT;
ALTER TABLE public.finance_records ADD COLUMN IF NOT EXISTS record_type TEXT DEFAULT 'Income';

-- 3. Enable RLS
ALTER TABLE public.finance_records ENABLE ROW LEVEL SECURITY;

-- 4. Set up Policies (Admin Only)
-- This uses the is_admin() helper created in earlier migration steps
DROP POLICY IF EXISTS "Admins have full access to finance" ON public.finance_records;
CREATE POLICY "Admins have full access to finance"
ON public.finance_records
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 5. Enable Realtime for live dashboard updates
ALTER TABLE public.finance_records REPLICA IDENTITY FULL;

-- 6. Refresh Schema Cache
NOTIFY pgrst, 'reload schema';
