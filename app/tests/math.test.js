const { add, subtract, multiply, divide, square } = require('../math');

describe('Math Functions Unit Tests', () => {
  test('adds 1 + 2 to equal 3', () => {
    expect(add(1, 2)).toBe(3);
  });

  test('subtracts 5 - 2 to equal 3', () => {
    expect(subtract(5, 2)).toBe(3);
  });

  test('multiplies 4 * 3 to equal 12', () => {
    expect(multiply(4, 3)).toBe(12);
  });

  test('divides 10 / 2 to equal 5', () => {
    expect(divide(10, 2)).toBe(5);
  });

  test('squares 4 to equal 16', () => {
    expect(square(4)).toBe(16);
  });
});
