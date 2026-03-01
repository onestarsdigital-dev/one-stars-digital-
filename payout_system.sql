
-- 1. PROFILES TABLE (Required for Role checking)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  email TEXT,
  is_admin BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. PAYOUT ACCOUNTS TABLE
CREATE TABLE IF NOT EXISTS public.payout_accounts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES auth.users NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('facebook', 'youtube', 'tiktok')),
  account_name TEXT NOT NULL,
  social_link TEXT NOT NULL,
  bank_type TEXT NOT NULL, -- KBZ, Wave, AYA, Binance USDT, Thai Bank, etc.
  bank_details TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  approved_by UUID REFERENCES auth.users,
  approved_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 3. PAYOUT TRANSACTIONS TABLE
CREATE TABLE IF NOT EXISTS public.payout_transactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  payout_account_id UUID REFERENCES public.payout_accounts ON DELETE CASCADE NOT NULL,
  client_id UUID REFERENCES auth.users NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'USD',
  payout_month TEXT NOT NULL, -- e.g., "Feb 2026"
  status TEXT NOT NULL DEFAULT 'processing' CHECK (status IN ('processing', 'paid', 'failed', 'on_hold')),
  invoice_url TEXT,
  created_by UUID REFERENCES auth.users NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 4. ADMIN CHECK HELPER
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. ENABLE RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_transactions ENABLE ROW LEVEL SECURITY;

-- 6. RLS POLICIES: PROFILES
CREATE POLICY "Users view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Admins manage profiles" ON public.profiles FOR ALL USING (public.is_admin());

-- 7. RLS POLICIES: PAYOUT_ACCOUNTS
CREATE POLICY "Admins manage payout_accounts" ON public.payout_accounts FOR ALL USING (public.is_admin());
CREATE POLICY "Clients view own approved/rejected accounts" ON public.payout_accounts FOR SELECT USING (auth.uid() = client_id);
CREATE POLICY "Clients insert pending requests" ON public.payout_accounts FOR INSERT WITH CHECK (auth.uid() = client_id AND status = 'pending');

-- 8. RLS POLICIES: PAYOUT_TRANSACTIONS
CREATE POLICY "Admins manage payout_transactions" ON public.payout_transactions FOR ALL USING (public.is_admin());
CREATE POLICY "Clients view own transactions" ON public.payout_transactions FOR SELECT USING (auth.uid() = client_id);

-- 9. STORAGE SETUP (Bucket: invoices)
-- Note: Make sure to create the 'invoices' bucket in the UI first or via SQL if supported
INSERT INTO storage.buckets (id, name, public) VALUES ('invoices', 'invoices', false) ON CONFLICT (id) DO NOTHING;

-- Admin can upload anything to invoices
CREATE POLICY "Admin upload invoices" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'invoices' AND public.is_admin());
CREATE POLICY "Admin manage invoices" ON storage.objects FOR ALL TO authenticated USING (bucket_id = 'invoices' AND public.is_admin());

-- Client can only read from their own client_id folder
CREATE POLICY "Client view own invoices" ON storage.objects FOR SELECT TO authenticated 
USING (bucket_id = 'invoices' AND (storage.foldername(name))[1] = auth.uid()::text);

-- 10. REALTIME CONFIG
ALTER TABLE public.payout_accounts REPLICA IDENTITY FULL;
ALTER TABLE public.payout_transactions REPLICA IDENTITY FULL;
