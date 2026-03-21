import { createContext, useContext, useEffect, useState } from "react";
import { api } from "../api";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("tw_token");
    if (!token) {
      setLoading(false);
      return;
    }
    api.me().then(setUser).catch(() => localStorage.removeItem("tw_token")).finally(() => setLoading(false));
  }, []);

  const login = async (payload, mode = "login") => {
    const fn = mode === "register" ? api.register : api.login;
    const data = await fn(payload);
    localStorage.setItem("tw_token", data.access_token);
    setUser(data.user);
    return data.user;
  };

  const logout = () => {
    localStorage.removeItem("tw_token");
    setUser(null);
  };

  return <AuthContext.Provider value={{ user, setUser, loading, login, logout }}>{children}</AuthContext.Provider>;
}

export function useAuth() {
  return useContext(AuthContext);
}
