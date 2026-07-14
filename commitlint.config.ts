import baseConfig from '@halospv3/hce.shared-config/commitlintConfig';

const scopes = {
  CHANGELOG: 'Affects "CHANGELOG.md".',
  commitlint: 'Affects this repo\'s commitlint config, esp. its commit scopes.',
  contributing: 'Affects CONTRIBUTING.md',
  'conv-pr': 'Affects ".github/workflows/conv-pull-requests.yml".',
  deps: 'Affects dependencies required at runtime.',
  'deps-dev':
    'Affects dependencies required in the dev environment or during build time.',
  eslint: 'Affects this repo\'s ESLint config.',
  README: 'Affects "README.md".',
  release: 'Reserved for release commits.',
  renovate: 'Affects "./.github/renovate.json".',
  TODO: 'Affects "TODO.md".',
  vscode: 'Affects ".vscode/".',
} as const;

baseConfig.rules['scope-enum'] = [
  2,
  'always',
  Object.keys(scopes),
];

export default baseConfig;
