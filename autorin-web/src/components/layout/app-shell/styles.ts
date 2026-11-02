import styled from "styled-components";
import { SHELL_COLORS } from "./constants";

export const PageFrame = styled.div`
  height: 100vh;
  overflow: hidden;
  background: ${SHELL_COLORS.cardBg};
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
  padding: 8px 22px 24px;
  background: ${SHELL_COLORS.cardBg};

  @media (max-width: 900px) {
    padding: 8px 16px 20px;
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
