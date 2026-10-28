import { useState, useEffect, useRef, useCallback } from "react";
import { useLanguage } from "@/lib/i18n";
import { SLIDER_ITEMS } from "../../constants";
import { AsteriskIcon } from "../AsteriskIcon";
import {
  SliderContainer,
  SlidesTrack,
  SlideItem,
  SlideImage,
  DarkOverlay,
  TopAsterisk,
  BottomContent,
  TextSection,
  SubtitleTag,
  SlideTitle,
  SlideDescription,
  DotsContainer,
  DotIndicator,
} from "./styles";

const AUTO_SWIPE_INTERVAL = 4000; // 4 soniya
const SWIPE_THRESHOLD = 45; // Swipe chegarasi (px)

export function BannerSlider() {
  const { t } = useLanguage();
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isPaused, setIsPaused] = useState(false);
  const [isDragging, setIsDragging] = useState(false);
  const [dragOffset, setDragOffset] = useState(0);
  const startXRef = useRef<number | null>(null);
  const frameWidthRef = useRef<number>(1);
  const containerRef = useRef<HTMLDivElement | null>(null);

  const totalSlides = SLIDER_ITEMS.length;

  const goToNext = useCallback(() => {
    setCurrentIndex((prev) => (prev + 1) % totalSlides);
  }, [totalSlides]);

  const goToPrev = useCallback(() => {
    setCurrentIndex((prev) => (prev - 1 + totalSlides) % totalSlides);
  }, [totalSlides]);

  const goToSlide = (index: number) => {
    setCurrentIndex(index);
  };

  // Avtomatik animatsiyali almashtirish (auto swipe)
  useEffect(() => {
    if (isPaused || isDragging) return;

    const timer = setInterval(() => {
      goToNext();
    }, AUTO_SWIPE_INTERVAL);

    return () => clearInterval(timer);
  }, [isPaused, isDragging, goToNext]);

  // Touch swipe (qo'lda barmoq bilan siljitish)
  const handleTouchStart = (e: React.TouchEvent<HTMLDivElement>) => {
    if (containerRef.current) {
      frameWidthRef.current = containerRef.current.clientWidth;
    }
    startXRef.current = e.touches[0].clientX;
    setIsDragging(true);
    setDragOffset(0);
  };

  const handleTouchMove = (e: React.TouchEvent<HTMLDivElement>) => {
    if (startXRef.current === null) return;
    const currentX = e.touches[0].clientX;
    const diff = currentX - startXRef.current;
    const percent = (diff / frameWidthRef.current) * 100;
    setDragOffset(percent);
  };

  const handleTouchEnd = () => {
    if (startXRef.current === null) return;
    const thresholdPercent = (SWIPE_THRESHOLD / frameWidthRef.current) * 100;

    if (dragOffset < -thresholdPercent) {
      goToNext();
    } else if (dragOffset > thresholdPercent) {
      goToPrev();
    }

    startXRef.current = null;
    setIsDragging(false);
    setDragOffset(0);
  };

  // Mouse drag swipe (Desktopda sichqoncha bilan siljitish)
  const handleMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    e.preventDefault();
    if (containerRef.current) {
      frameWidthRef.current = containerRef.current.clientWidth;
    }
    startXRef.current = e.clientX;
    setIsDragging(true);
    setDragOffset(0);
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!isDragging || startXRef.current === null) return;
    const diff = e.clientX - startXRef.current;
    const percent = (diff / frameWidthRef.current) * 100;
    setDragOffset(percent);
  };

  const handleMouseUp = () => {
    if (!isDragging || startXRef.current === null) return;
    const thresholdPercent = (SWIPE_THRESHOLD / frameWidthRef.current) * 100;

    if (dragOffset < -thresholdPercent) {
      goToNext();
    } else if (dragOffset > thresholdPercent) {
      goToPrev();
    }

    startXRef.current = null;
    setIsDragging(false);
    setDragOffset(0);
  };

  const handleMouseLeave = () => {
    if (isDragging) {
      handleMouseUp();
    }
    setIsPaused(false);
  };

  const currentSlide = SLIDER_ITEMS[currentIndex];
  const computedOffset = -currentIndex * 100 + (isDragging ? dragOffset : 0);

  return (
    <SliderContainer
      ref={containerRef}
      onMouseEnter={() => setIsPaused(true)}
      onMouseLeave={handleMouseLeave}
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
      onMouseDown={handleMouseDown}
      onMouseMove={handleMouseMove}
      onMouseUp={handleMouseUp}
    >
      {/* 3 ta to'liq qoplovchi rasm: auto va qo'lda silliq swipe */}
      <SlidesTrack $offset={computedOffset} $animating={!isDragging}>
        {SLIDER_ITEMS.map((item, index) => (
          <SlideItem key={item.id}>
            <SlideImage
              src={item.image}
              alt={t(item.alt)}
              $active={index === currentIndex}
            />
          </SlideItem>
        ))}
      </SlidesTrack>

      {/* Rasm ustidagi silliq qorong'ilashtiruvchi gradient overlay */}
      <DarkOverlay />

      {/* Yuqori chapdagi Asterisk belgisi (Mockupdagidek) */}
      <TopAsterisk>
        <AsteriskIcon size={34} color="#ffffff" />
      </TopAsterisk>

      {/* Slayderning pastki qismida avtomatik animatsiya bilan chiquvchi matnlar va dotlar */}
      <BottomContent>
        <TextSection key={currentSlide.id}>
          <SubtitleTag>{t(currentSlide.subtitle)}</SubtitleTag>
          <SlideTitle>{t(currentSlide.title)}</SlideTitle>
          <SlideDescription>{t(currentSlide.description)}</SlideDescription>
        </TextSection>

        {/* 3 ta dot slayder rasmning eng pasida turadi */}
        <DotsContainer>
          {SLIDER_ITEMS.map((_, index) => (
            <DotIndicator
              key={index}
              $active={index === currentIndex}
              onClick={(e) => {
                e.stopPropagation();
                goToSlide(index);
              }}
              aria-label={`Slide ${index + 1}`}
            />
          ))}
        </DotsContainer>
      </BottomContent>
    </SliderContainer>
  );
}
