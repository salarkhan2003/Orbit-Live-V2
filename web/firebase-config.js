// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyAAiH5whjhfoGyw83uwji0Con8nojaXBFA",
  authDomain: "orbit-live.firebaseapp.com",
  projectId: "orbit-live",
  storageBucket: "orbit-live.firebasestorage.app",
  messagingSenderId: "563483124508",
  appId: "1:563483124508:web:9e3f2b3d1e732fe25050d9"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
