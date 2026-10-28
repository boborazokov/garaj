import styled from "styled-components";

export const SliderContainer = styled.div`
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
  overflow: hidden;
  cursor: grab;
  user-select: none;
  background-color: #0f172a;

  &:active {
    cursor: grabbing;
  }
`;

export const SlidesTrack = styled.div<{ $offset: number; $animating: boolean }>`
  display: flex;
  width: 100%;
  height: 100%;
  transform: translateX(${(props) => props.$offset}%);
  transition: ${(props) =>
    props.$animating
      ? "transform 0.65s cubic-bezier(0.22, 1, 0.36, 1)"
      : "none"};
`;

export const SlideItem = styled.div`
  position: relative;
  min-width: 100%;
  width: 100%;
  height: 100%;
  flex-shrink: 0;
  overflow: hidden;
`;

export const SlideImage = styled.img<{ $active?: boolean }>`
  width: 100%;
  height: 100%;
  object-fit: cover;
  object-position: center;
  display: block;
  pointer-events: none;
  transition: transform 6s ease-out;
  transform: ${(props) => (props.$active ? "scale(1.04)" : "scale(1)")};
`;

export const DarkOverlay = styled.div`
  position: absolute;
  inset: 0;
  background: linear-gradient(
    180deg,
    rgba(10, 16, 28, 0.45) 0%,
    rgba(10, 16, 28, 0.08) 30%,
    rgba(10, 16, 28, 0.55) 60%,
    rgba(10, 16, 28, 0.94) 100%
  );
  pointer-events: none;
`;

export const TopAsterisk = styled.div`
  position: absolute;
  top: 36px;
  left: 36px;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: auto;

  @media (max-width: 960px) {
    top: 24px;
    left: 24px;
  }
`;

export const BottomContent = styled.div`
  position: absolute;
  bottom: 38px;
  left: 38px;
  right: 38px;
  z-index: 10;
  display: flex;
  flex-direction: column;
  gap: 16px;
  pointer-events: auto;

  @media (max-width: 960px) {
    bottom: 24px;
    left: 24px;
    right: 24px;
    gap: 12px;
  }
`;

export const TextSection = styled.div`
  display: flex;
  flex-direction: column;
  gap: 8px;
  min-height: 90px;
  animation: slideTextIn 0.5s cubic-bezier(0.16, 1, 0.3, 1) forwards;

  @keyframes slideTextIn {
    0% {
      opacity: 0;
      transform: translateY(16px);
    }
    100% {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @media (max-width: 960px) {
    min-height: auto;
  }
`;

export const SubtitleTag = styled.span`
  color: rgba(255, 255, 255, 0.85);
  font-size: 14px;
  font-weight: 500;
  letter-spacing: -0.1px;
  text-shadow: 0 1px 3px rgba(0, 0, 0, 0.4);
`;

export const SlideTitle = styled.h3`
  color: #ffffff;
  font-size: 27px;
  font-weight: 700;
  margin: 0;
  line-height: 1.25;
  letter-spacing: -0.5px;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.45);

  @media (max-width: 1200px) {
    font-size: 23px;
  }

  @media (max-width: 960px) {
    font-size: 20px;
  }
`;

export const SlideDescription = styled.p`
  color: rgba(255, 255, 255, 0.88);
  font-size: 14.5px;
  line-height: 1.5;
  margin: 0;
  letter-spacing: -0.1px;
  text-shadow: 0 1px 4px rgba(0, 0, 0, 0.35);

  @media (max-width: 960px) {
    font-size: 13.5px;
  }
`;

export const DotsContainer = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
  padding-top: 4px;
`;

export const DotIndicator = styled.button<{ $active?: boolean }>`
  height: 6px;
  width: ${(props) => (props.$active ? "26px" : "6px")};
  border-radius: 4px;
  background-color: ${(props) =>
    props.$active ? "#ffffff" : "rgba(255, 255, 255, 0.45)"};
  border: none;
  padding: 0;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
  outline: none;

  &:hover {
    background-color: #ffffff;
  }
`;
