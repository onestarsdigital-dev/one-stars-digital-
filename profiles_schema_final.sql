
-- 1. Create a robust admin check function that avoids table recursion
-- This function is used by OTHER tables to check if a user is an admin.
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN (
    -- Primary Check: Master Email in JWT
    (auth.jwt() ->> 'email' = 'admin@onestars.digital')
    OR
    -- Secondary Check: Look up the flag directly in the auth metadata 
    -- (Assuming you have a trigger syncing is_admin to auth.users.raw_app_meta_data)
    ((auth.jwt() -> 'app_metadata') ->> 'is_admin')::boolean = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Ensure the profiles table has all required columns
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS telegram TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS whatsapp TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS phone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS country TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS timezone TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS niche TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS bio TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS website TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS usdt_address TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'Active';
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

-- 3. Reset RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 4. Recreate policies WITHOUT calling public.is_admin() to avoid infinite recursion
-- The recursion happens because: Policy calls is_admin() -> is_admin() selects from profiles -> trigger policy...
DROP POLICY IF EXISTS "Profiles are viewable by authenticated users" ON public.profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Users can insert their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins have full access to profiles" ON public.profiles;
DROP POLICY IF EXISTS "Users view own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins manage profiles" ON public.profiles;
DROP POLICY IF EXISTS "Global Access" ON public.profiles;

-- Anyone authenticated can view their own profile or public profiles
CREATE POLICY "Profiles_Select_Policy" 
ON public.profiles FOR SELECT 
TO authenticated 
USING (
  auth.uid() = id 
  OR 
  (auth.jwt() ->> 'email' = 'admin@onestars.digital')
);

-- Users can only modify their own profile record
-- We check columns directly, NOT calling the is_admin() function
CREATE POLICY "Profiles_Update_Policy" 
ON public.profiles FOR UPDATE 
TO authenticated 
USING (
  auth.uid() = id 
  OR 
  (auth.jwt() ->> 'email' = 'admin@onestars.digital')
)
WITH CHECK (
  auth.uid() = id 
  OR 
  (auth.jwt() ->> 'email' = 'admin@onestars.digital')
);

-- Users can insert their own profile on signup
CREATE POLICY "Profiles_Insert_Policy" 
ON public.profiles FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = id);

-- Admins have full access (Direct column reference to avoid function loop)
CREATE POLICY "Profiles_Admin_Master_Policy" 
ON public.profiles FOR ALL 
TO authenticated 
USING (
  (auth.jwt() ->> 'email' = 'admin@onestars.digital')
)
WITH CHECK (
  (auth.jwt() ->> 'email' = 'admin@onestars.digital')
);

-- 5. Enable Realtime
ALTER TABLE public.profiles REPLICA IDENTITY FULL;
