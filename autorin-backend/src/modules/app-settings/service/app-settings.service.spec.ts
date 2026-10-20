import { isProductModerationOn } from './app-settings.service';

describe('isProductModerationOn', () => {
  it('keeps an administrator choice of off', () => {
    expect(isProductModerationOn(false)).toBe(false);
  });

  it('treats enabled and missing values as on', () => {
    expect(isProductModerationOn(true)).toBe(true);
    expect(isProductModerationOn(undefined)).toBe(true);
    expect(isProductModerationOn(null)).toBe(true);
  });
});
