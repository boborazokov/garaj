import styled from "styled-components";
import { SIGN_IN_COLORS } from "./constants";

export const PageContainer = styled.main`
  width: 100vw;
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background-color: #ffffff;
  margin: 0;
  padding: 24px;
  box-sizing: border-box;

  @media (max-width: 900px) {
    padding: 0;
    align-items: stretch;
  }
`;

export const FormSection = styled.section`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: space-between;
  background-color: #ffffff;
  height: 100%;
  min-height: 760px;
  width: 100%;
  padding: 40px 48px 20px;
  box-sizing: border-box;
  overflow-y: auto;

  @media (max-width: 900px) {
    height: auto;
    min-height: 100vh;
    padding: 32px 20px 20px;
  }
`;

export const AuthCard = styled.div`
  display: grid;
  grid-template-columns: 1fr 1fr;
  width: min(1200px, 100%);
  min-height: 760px;
  background: #ffffff;
  border-radius: 28px;
  overflow: hidden;
  box-shadow: 0 30px 80px -30px rgba(15, 23, 42, 0.25);

  @media (max-width: 900px) {
    grid-template-columns: 1fr;
    width: 100%;
    min-height: 100vh;
    border-radius: 0;
    box-shadow: none;
  }
`;

export const FormCenterWrapper = styled.div`
  width: 100%;
  max-width: 420px;
  margin: auto 0;
  display: flex;
  flex-direction: column;
  flex: 1;
  justify-content: center;
`;

export const FormHeader = styled.header`
  text-align: left;
  margin-bottom: 20px;
`;

export const BrandStarWrapper = styled.div`
  margin-bottom: 14px;
  display: flex;
  align-items: center;
`;

export const FormTitle = styled.h1`
  font-size: 32px;
  font-weight: 700;
  color: ${SIGN_IN_COLORS.textPrimary};
  margin: 0 0 10px 0;
  letter-spacing: -0.6px;
  line-height: 1.2;

  @media (max-width: 600px) {
    font-size: 26px;
  }
`;

export const FormSubtitle = styled.p`
  font-size: 14px;
  color: ${SIGN_IN_COLORS.textSecondary};
  margin: 0;
  line-height: 1.5;
  letter-spacing: -0.1px;
`;

