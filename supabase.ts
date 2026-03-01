
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://pmlfacxcbgiehjzvmmuv.supabase.co'; 
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtbGZhY3hjYmdpZWhqenZtbXV2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAwMjU4OTIsImV4cCI6MjA4NTYwMTg5Mn0.KGth-Za5o9_1fwdCU-_ZC-QFvK65B9C-Ypbh4IQBUaM';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

/**
 * Standard Password Login
 */
export async function loginAndRoute(email: string, password: string) {
  const cleanEmail = email.trim().toLowerCase();
  console.log(`[Auth Protocol] Standard Request: ${cleanEmail}`);
  
  const { data, error } = await supabase.auth.signInWithPassword({
    email: cleanEmail,
    password: password.trim(),
  });

  if (error) {
    console.error("[Auth Failure]", error.message);
    throw error;
  }
  return data;
}

/**
 * Magic Link Login (Bypasses password issues)
 */
export async function signInWithMagicLink(email: string) {
  const cleanEmail = email.trim().toLowerCase();
  console.log(`[Auth Protocol] Magic Link Request: ${cleanEmail}`);
  
  const { error } = await supabase.auth.signInWithOtp({
    email: cleanEmail,
    options: {
      emailRedirectTo: window.location.origin,
    }
  });

  if (error) {
    console.error("[Magic Link Failure]", error.message);
    throw error;
  }
}
