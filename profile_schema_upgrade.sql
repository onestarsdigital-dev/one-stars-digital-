-- 1. Profiles table တွင် လိုအပ်သော Column များမရှိပါက ထည့်သွင်းမည်
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS full_name TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS telegram TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS whatsapp TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS country TEXT;
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS timezone TEXT;

-- 2. Row Level Security (RLS) ကို ဖွင့်မည်
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 3. အသုံးပြုသူများသည် မိမိတို့၏ Profile ကိုသာ ကြည့်ရှု/ပြင်ဆင်နိုင်ရန် Policy သတ်မှတ်မည်

-- (A) Select Policy
DROP POLICY IF EXISTS "Users can view own profile" ON public.profiles;
CREATE POLICY "Users can view own profile" 
ON public.profiles 
FOR SELECT 
TO authenticated 
USING (auth.uid() = id);

-- (B) Update Policy (ဤအချက်သည် Identity Sync အလုပ်လုပ်ရန် အဓိကလိုအပ်ချက်ဖြစ်သည်)
DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" 
ON public.profiles 
FOR UPDATE 
TO authenticated 
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- (C) Insert Policy
DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
CREATE POLICY "Users can insert own profile" 
ON public.profiles 
FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid() = id);

-- 4. Realtime UI update များအတွက် REPLICA IDENTITY ကို FULL ပြောင်းမည်
ALTER TABLE public.profiles REPLICA IDENTITY FULL;

-- 5. Admin role ရှိမရှိစစ်ဆေးသော function (လိုအပ်ပါက)
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND is_admin = true
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;