
-- 1. Global Tool Registry (Master List)
CREATE TABLE IF NOT EXISTS public.tool_registry (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  key TEXT UNIQUE NOT NULL, -- e.g. 'Overview', 'Marketplace'
  title TEXT NOT NULL,
  icon_key TEXT NOT NULL, -- Lucide icon name
  route TEXT NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Client-Specific Tool Assignment
CREATE TABLE IF NOT EXISTS public.client_tools (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES auth.users ON DELETE CASCADE NOT NULL,
  tool_key TEXT REFERENCES public.tool_registry(key) ON DELETE CASCADE NOT NULL,
  enabled BOOLEAN DEFAULT true,
  pinned BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  UNIQUE(client_id, tool_key) -- Ensure no duplicates per user
);

-- 3. Seed Initial Tools (Must match current UI keys exactly)
INSERT INTO public.tool_registry (key, title, icon_key, route)
VALUES 
  ('Overview', 'Control Center', 'LayoutDashboard', 'Overview'),
  ('Marketplace', 'Digital Assets', 'ShoppingBag', 'Marketplace'),
  ('Services', 'Monetization Hub', 'Zap', 'Services'),
  ('Payouts', 'Earnings Ledger', 'Banknote', 'Payouts'),
  ('Academy', 'Elite Academy', 'GraduationCap', 'Academy'),
  ('Tools', 'Creative Studio', 'Award', 'Tools'),
  ('Registry', 'Identity Config', 'User', 'Registry'),
  ('Notifications', 'Update Center', 'Bell', 'Notifications'),
  ('Support', 'Support Hub', 'LifeBuoy', 'Support'),
  ('Activity', 'Activity Log', 'History', 'Activity')
ON CONFLICT (key) DO UPDATE SET 
  title = EXCLUDED.title,
  icon_key = EXCLUDED.icon_key;

-- 4. Enable RLS
ALTER TABLE public.tool_registry ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.client_tools ENABLE ROW LEVEL SECURITY;

-- 5. Policies
CREATE POLICY "Registry is public read" ON public.tool_registry FOR SELECT USING (true);

CREATE POLICY "Clients can view their assigned tools" 
ON public.client_tools FOR SELECT 
USING (auth.uid() = client_id);

CREATE POLICY "Admins have full control over client tools" 
ON public.client_tools FOR ALL 
USING (public.is_admin()) 
WITH CHECK (public.is_admin());

-- 6. Realtime
ALTER TABLE public.tool_registry REPLICA IDENTITY FULL;
ALTER TABLE public.client_tools REPLICA IDENTITY FULL;
