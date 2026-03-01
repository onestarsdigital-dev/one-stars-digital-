
-- 1. Create Payout Risk Logs Table
CREATE TABLE IF NOT EXISTS public.payout_risk_logs (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  client_id UUID REFERENCES auth.users(id) NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('facebook', 'youtube', 'tiktok', 'instagram', 'telegram', 'social media')),
  risk_type TEXT NOT NULL CHECK (risk_type IN ('Delay', 'Threshold', 'Country', 'Bank', 'Platform')),
  risk_level TEXT NOT NULL CHECK (risk_level IN ('Stable', 'Watch', 'At Risk', 'Critical')),
  message_client TEXT NOT NULL,
  message_internal TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'Open' CHECK (status IN ('Open', 'Monitoring', 'Resolved')),
  detected_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  resolved_at TIMESTAMP WITH TIME ZONE,
  internal_ai_score INTEGER DEFAULT 0
);

-- 2. Enable RLS
ALTER TABLE public.payout_risk_logs ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Admins: Global full access
CREATE POLICY "Admins have full access to payout risk logs"
ON public.payout_risk_logs
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Clients: Restricted view access to their own logs
CREATE POLICY "Clients can view their own payout risk signals"
ON public.payout_risk_logs
FOR SELECT
TO authenticated
USING (auth.uid() = client_id);

-- 4. Enable Realtime
ALTER TABLE public.payout_risk_logs REPLICA IDENTITY FULL;
