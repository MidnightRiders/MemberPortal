/** @type {import('stylelint').Config} */
const config = {
  extends: ['stylelint-config-standard', 'stylelint-config-prettier'],
  rules: {
    'at-rule-no-unknown': [
      true,
      {
        ignoreAtRules: ['define-mixin', 'mixin'],
      },
    ],
    'custom-property-pattern': '^[a-z][a-zA-Z0-9]+$',
    'font-family-name-quotes': 'always-where-recommended',
    'keyframes-name-pattern': '^[a-z][a-zA-Z0-9]+$',
    'no-descending-specificity': null,
    'selector-class-pattern': '^([a-z][a-zA-Z0-9]+|bi-[a-z0-9-]+)$',
    'selector-pseudo-class-no-unknown': [
      true,
      { ignorePseudoClasses: 'global' },
    ],
  },
};

module.exports = config;
