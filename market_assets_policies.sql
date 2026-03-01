
-- 1. Ensure RLS is enabled for market_assets
ALTER TABLE public.market_assets ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies to prevent conflicts
DROP POLICY IF EXISTS "Public read market_assets" ON public.market_assets;
DROP POLICY IF EXISTS "Admin manage market_assets" ON public.market_assets;

-- 3. Public/Clients: Can read all available assets
CREATE POLICY "Public read market_assets"
ON public.market_assets
FOR SELECT
TO public
USING (true);

-- 4. Admins: Global CRUD access (Create, Read, Update, Delete)
-- This uses the existing public.is_admin() function
CREATE POLICY "Admin manage market_assets"
ON public.market_assets
FOR ALL
TO authenticated
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- 5. Ensure the table allows identity management for inserts
ALTER TABLE public.market_assets REPLICA IDENTITY FULL;
