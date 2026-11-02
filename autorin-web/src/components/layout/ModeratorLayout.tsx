import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { getUser, isModerator } from "../../lib/auth";
import { AppShell, MODERATOR_NAV_GROUPS } from "./app-shell";

export function ModeratorLayout() {
  const navigate = useNavigate();
  const user = getUser();

  useEffect(() => {
    if (!isModerator(user)) navigate("/sign-in", { replace: true });
  }, [user, navigate]);

  if (!isModerator(user) || !user) return null;

  return (
    <AppShell user={user} groups={MODERATOR_NAV_GROUPS} homeTo="/moderator" />
  );
}
