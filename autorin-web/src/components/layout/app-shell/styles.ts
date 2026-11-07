import styled from "styled-components";
import { SHELL_COLORS } from "./constants";

export const PageFrame = styled.div`
  height: 100vh;
  overflow: hidden;
  background: ${SHELL_COLORS.cardBg};
  font-family: "Inter", ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI",
    sans-serif;
  -webkit-font-smoothing: antialiased;
`;

export const ShellCard = styled.div`
  display: flex;
  height: 100%;
  min-height: 0;
  background: ${SHELL_COLORS.cardBg};
  overflow: hidden;
`;

export const ContentColumn = styled.div`
  display: flex;
  flex-direction: column;
  flex: 1;
  min-width: 0;
  min-height: 0;
  height: 100%;
  background: ${SHELL_COLORS.cardBg};
`;

export const MainArea = styled.main`
  flex: 1;
  min-height: 0;
  overflow: auto;
  padding: 12px 22px 28px;
  background: ${SHELL_COLORS.cardBg};

  @media (max-width: 900px) {
    padding: 10px 16px 22px;
  }
`;

export const Backdrop = styled.button`
  display: none;

  @media (max-width: 900px) {
    display: block;
    position: fixed;
    inset: 0;
    border: 0;
    background: rgba(15, 23, 42, 0.28);
    z-index: 40;
    cursor: pointer;
  }
`;
