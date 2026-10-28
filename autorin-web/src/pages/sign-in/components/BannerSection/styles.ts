import styled from "styled-components";

export const BannerContainer = styled.section`
  position: relative;
  width: 100%;
  height: 100%;
  border-radius: 24px;
  overflow: hidden;
  background-color: #0f172a;
  box-shadow: 0 10px 30px -5px rgba(0, 0, 0, 0.15);

  @media (max-width: 900px) {
    display: none;
  }
`;
