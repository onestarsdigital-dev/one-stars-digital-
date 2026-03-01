
-- 1. Create Notifications Table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('system_update', 'admin_message', 'security_alert')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  target_user_id UUID REFERENCES auth.users(id), -- Nullable for global broadcasts
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Anyone (Authenticated) can view notifications
CREATE POLICY "Users can view relevant notifications"
ON public.notifications
FOR SELECT
TO authenticated
USING (target_user_id IS NULL OR target_user_id = auth.uid());

-- Only Admins can manage notifications
CREATE POLICY "Admins have full control over notifications"
ON public.notifications
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 4. Realtime
ALTER TABLE public.notifications REPLICA IDENTITY FULL;
