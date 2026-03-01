
import { initializeApp, getApp, getApps } from "firebase/app";
import { getFirestore } from "firebase/firestore";
import { getAuth } from "firebase/auth";
import { getStorage } from "firebase/storage";

const firebaseConfig = {
  apiKey: process.env.API_KEY,
  authDomain: "one-stars-digital.firebaseapp.com",
  projectId: "one-stars-digital",
  storageBucket: "one-stars-digital.appspot.com",
  messagingSenderId: "1234567890",
  appId: "1:1234567890:web:abcdef123456"
};

let app;
try {
  // Check if API key is valid format
  const isKeyValid = firebaseConfig.apiKey && 
                     firebaseConfig.apiKey.length > 10 && 
                     !firebaseConfig.apiKey.includes('YOUR_');

  if (!isKeyValid) {
    console.warn("Firebase: Placeholder or invalid API Key detected. Using local simulation mode.");
    app = !getApps().length ? initializeApp({ ...firebaseConfig, apiKey: "dummy-key" }) : getApp();
  } else {
    app = !getApps().length ? initializeApp(firebaseConfig) : getApp();
  }
} catch (error) {
  console.error("Firebase Initialization Error:", error);
  app = { options: {}, name: '[DEFAULT]' } as any;
}

export const db = getFirestore(app);
export const auth = getAuth(app);
export const storage = getStorage(app);
