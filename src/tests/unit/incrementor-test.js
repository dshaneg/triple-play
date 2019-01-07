const { expect } = require('chai');
const Incrementor = require('../../lib/incrementor');

describe('Incrementor', () => {
  describe('Increment', () => {
    it('Should increment 2 to 5 with increment value of 3.', () => {
      const incrementor = new Incrementor(3);
      expect(incrementor.Increment(2)).to.equal(5);
    });

    it('Should increment 2 to 3 with no increment value passed.', () => {
      const incrementor = new Incrementor();
      expect(incrementor.Increment(2)).to.equal(3);
    });

    it('Should increment 2 to 2 with increment value of 0.', () => {
      const incrementor = new Incrementor(0);
      expect(incrementor.Increment(2)).to.equal(2);
    });
  });
});
