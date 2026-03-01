
import { supabase } from "./supabase";
import { withTimeout } from "./async";

/**
 * Standardized high-security logout protocol for One Stars Hub.
 * Forcefully terminates session on server and wipes all browser-side traces.
 */
export async function performLogout() {
  console.log("[Auth] Initiating Global Termination Sequence...");
  
  try {
    // 1. Attempt Server-side Sign-out with a 5-second deadline
    // This invalidates the refresh token on the Supabase backend
    await withTimeout(
      supabase.auth.signOut({ scope: 'global' }),
      5000,
      "Server logout timed out. Proceeding with local purge."
    ).catch(err => {
      console.warn("[Auth] SignOut Protocol Warning:", err.message);
    });

    // 2. Absolute Cache and Storage Purge
    // We clear everything to remove custom settings, tokens, and navigation history
    localStorage.clear();
    sessionStorage.clear();
    
    // 3. Selective Supabase Key Removal
    // Just in case clear() missed something, we target standard Supabase keys
    const sbKeys = Object.keys(localStorage).filter(k => k.startsWith('sb-'));
    sbKeys.forEach(k => localStorage.removeItem(k));

    // 4. Absolute Cookie Sweep
    // Prevents session hijacking via lingering cookies
    const cookies = document.cookie.split(";");
    for (let i = 0; i < cookies.length; i++) {
      const cookie = cookies[i];
      const eqPos = cookie.indexOf("=");
      const name = eqPos > -1 ? cookie.substr(0, eqPos).trim() : cookie.trim();
      
      const expiry = "expires=Thu, 01 Jan 1970 00:00:00 GMT";
      document.cookie = `${name}=;${expiry};path=/;`;
      document.cookie = `${name}=;${expiry};path=/;domain=${window.location.hostname};`;
      // Handle potential subdomains
      const domainParts = window.location.hostname.split('.');
      if (domainParts.length > 2) {
        const rootDomain = domainParts.slice(-2).join('.');
        document.cookie = `${name}=;${expiry};path=/;domain=.${rootDomain};`;
      }
    }

    // 5. Channel Cleanup
    // Detach all realtime listeners to free up browser sockets
    // We don't await this to prevent hanging the logout sequence
    supabase.removeAllChannels().catch(() => {});
    
    console.log("[Auth] Clean Sweep Complete. Hard Redirecting...");

    // 6. Nuclear Navigation
    // location.replace() destroys the current history entry so 'Back' won't work
    // We use a small delay to ensure storage operations complete
    setTimeout(() => {
      window.location.replace(window.location.origin);
    }, 100);
    
  } catch (err: any) {
    console.error("[Auth] Critical Logout Failure:", err.message);
    // Absolute fallback: force wipe and hard reload anyway
    localStorage.clear();
    sessionStorage.clear();
    setTimeout(() => {
      window.location.replace(window.location.origin);
    }, 100);
  }
}
