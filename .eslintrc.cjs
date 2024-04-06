/* eslint-disable import/no-extraneous-dependencies, @typescript-eslint/no-var-requires */

/** @type {import('eslint').Linter.Config} */
const config = {
  extends: [
    require.resolve('@bensaufley/eslint-config/preact.cjs'),
  ],
};

module.exports = config;
