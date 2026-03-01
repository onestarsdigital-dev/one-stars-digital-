
-- 1. Create Product Reviews Table
CREATE TABLE IF NOT EXISTS public.product_reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  product_id TEXT NOT NULL,
  user_id UUID REFERENCES auth.users NOT NULL,
  user_name TEXT NOT NULL,
  rating INTEGER CHECK (rating >= 1 AND rating <= 5),
  comment TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())
);

-- 2. Enable RLS
ALTER TABLE public.product_reviews ENABLE ROW LEVEL SECURITY;

-- 3. RLS POLICIES
-- Anyone (Global) can view reviews
CREATE POLICY "Reviews are viewable by everyone"
ON public.product_reviews
FOR SELECT
TO authenticated, anon
USING (true);

-- Only logged in users can insert their own review
CREATE POLICY "Users can create their own reviews"
ON public.product_reviews
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 4. Enable Realtime
ALTER TABLE public.product_reviews REPLICA IDENTITY FULL;
