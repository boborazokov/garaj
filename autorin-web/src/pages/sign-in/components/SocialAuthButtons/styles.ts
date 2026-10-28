import styled from "styled-components";

export const DividerWrapper = styled.div`
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 22px 0 16px 0;
  width: 100%;
`;

export const DividerLine = styled.div`
  flex: 1;
  height: 1px;
  background-color: #e5e7eb;
`;

export const DividerText = styled.span`
  color: #9ca3af;
  font-size: 12px;
  padding: 0 12px;
  font-weight: 500;
  user-select: none;
`;

export const SocialRow = styled.div`
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
  width: 100%;
  margin-bottom: 20px;
`;

export const SocialPill = styled.button`
  height: 38px;
  background-color: #f1f3f7;
  border: 1px solid transparent;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  color: #1e293b;
  outline: none;

  &:hover {
    background-color: #e5e9f2;
    border-color: #d1d5db;
    transform: translateY(-1px);
    box-shadow: 0 4px 10px rgba(0, 0, 0, 0.06);
  }

  &:active {
    transform: translateY(0);
    background-color: #dbe0ea;
  }
`;
