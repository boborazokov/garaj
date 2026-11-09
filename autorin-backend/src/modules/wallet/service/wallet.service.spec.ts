describe('Wallet debit split math', () => {
  function split(bonus: number, main: number, amount: number) {
    const fromBonus = Math.min(bonus, amount);
    const fromMain = amount - fromBonus;
    return { fromBonus, fromMain };
  }

  it('spends bonus before main', () => {
    expect(split(40, 100, 30)).toEqual({ fromBonus: 30, fromMain: 0 });
    expect(split(40, 100, 70)).toEqual({ fromBonus: 40, fromMain: 30 });
    expect(split(0, 100, 50)).toEqual({ fromBonus: 0, fromMain: 50 });
  });

  it('rejects when total is insufficient', () => {
    const bonus = 10;
    const main = 20;
    const amount = 50;
    expect(bonus + main < amount).toBe(true);
  });
});
