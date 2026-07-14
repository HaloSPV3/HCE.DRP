import baseConfig from '@halospv3/hce.shared-config';
import type { PluginSpecSRCommitAnalyzer } from '@halospv3/hce.shared-config/semanticReleaseConfig';
import { strictEqual } from 'node:assert/strict';

const commitAnalyzer = baseConfig.plugins[0] as PluginSpecSRCommitAnalyzer;
strictEqual(commitAnalyzer[0], '@semantic-release/commit-analyzer');
commitAnalyzer[1].releaseRules = [
  { type: 'revert', subject: '!(feat|fix|perf)', release: false },
  { type: 'revert', subject: '(build|chore|ci|docs|refactor|revert|style|test)', release: false },
];

export default baseConfig;
