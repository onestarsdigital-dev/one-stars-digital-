
import { auth } from "./firebase";
import { setPersistence, browserLocalPersistence } from "firebase/auth";

/**
 * Initializes Firebase Authentication persistence.
 * This ensures that the user session is maintained across page reloads
 * by storing the auth state in the browser's local storage.
 */
export async function initAuthPersistence() {
  try {
    await setPersistence(auth, browserLocalPersistence);
  } catch (error) {
    console.error("Auth persistence initialization failed:", error);
  }
}
