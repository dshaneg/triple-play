class Incrementor {
  constructor(incrementValue) {
    if (incrementValue !== 0 && !incrementValue) {
      this.incrementValue = 1;
    } else {
      this.incrementValue = incrementValue;
    }
  }

  Increment(num) {
    return num + this.incrementValue;
  }
}

module.exports = Incrementor;
