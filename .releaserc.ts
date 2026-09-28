/// <reference types="@halospv3/hce.shared-config/semantic-release__commit-analyzer" />
/// <reference types="@halospv3/hce.shared-config/semantic-release__github" />
import { type PluginSpecSRCommitAnalyzer, type PluginSpecSRGithub, type PluginSpecSRReleaseNotesGen } from '@halospv3/hce.shared-config/semanticReleaseConfig';
import { getConfig } from '@halospv3/hce.shared-config/semanticReleaseConfigDotnet';
import '@semantic-release/changelog';
import '@semantic-release/commit-analyzer';
import type { RuleObjects } from '@semantic-release/commit-analyzer';
import '@semantic-release/exec';
import '@semantic-release/git';
import '@semantic-release/github';
import '@semantic-release/release-notes-generator';
import { exit } from 'node:process';
import 'semantic-release-export-data';



// https://github.com/semantic-release/github/blob/master/README.md#Options:~:text=releaseBodyTemplate
// halocepresence 1.0.6-alpha.169 (native).zip'
const githubReleaseAssetHint = /* md */ `\
## Which File?

- halocepresence $VERSION (native win-x86).zip
  - halocepresence.dll
    If you are using Monolith Mod Loader or Chimera >=1.0 (where Monolith Mod Loader is bundled or built-in);
    then copy this DLL to \`$GAME_FOLDER/mods/halocepresence.dll\`.
    Otherwise, copy it to \`$GAME_FOLDER/controls/halocepresence.dll\`.
`;
const projectsToPublish = ['src/DRP.nativeproj'];

let config: Awaited<ReturnType<typeof getConfig>>;
try {
  // getConfig is intended for C#/F#/VB projects where Pack and Publish targets
  // are similar if not identical. This "Native" project (not a Visual C++
  // .vcxproj!) uses a different Publish target, but seems to work as long as
  // the build output is copied to $(PublishDir)
  config = await getConfig(projectsToPublish);
}
catch (error: unknown) {
  const _error = Error.isError(error)
    ? error
    : new Error('unknown error', { cause: error });
  console.error(_error);
  exit (1);
}

config.branches ??= [];
if (typeof config.branches === 'string' || !('find' in config.branches))
  config.branches = [config.branches];
const developmentBranch = config.branches.find(branch =>
  typeof branch !== 'string' && branch.name === 'develop',
) as Exclude<typeof config.branches[number], string>;
developmentBranch.prerelease = 'alpha';

const commitAnalyzer = config.plugins?.find<PluginSpecSRCommitAnalyzer>(
  (p): p is PluginSpecSRCommitAnalyzer => p[0] === '@semantic-release/commit-analyzer',
);
if (commitAnalyzer) {
  const releaseRules = (
    typeof commitAnalyzer[1].releaseRules === 'string'
      ? (await import(commitAnalyzer[1].releaseRules) as (Exclude<typeof commitAnalyzer[1]['releaseRules'], string>))
      : commitAnalyzer[1].releaseRules
  ) ?? [];
  commitAnalyzer[1].releaseRules = [
    ...releaseRules,
    { type: 'revert', subject: '!(feat|fix|perf)', release: false },
    { type: 'revert', subject: '(build|chore|ci|docs|refactor|revert|style|test)', release: false },
  ] as RuleObjects.ConventionalCommits[];
}

const releaseNotesGen = config.plugins?.find<PluginSpecSRReleaseNotesGen>(
  (p): p is PluginSpecSRReleaseNotesGen => p[0] === '@semantic-release/release-notes-generator',
);
if (releaseNotesGen) {
  releaseNotesGen[1].preset = 'conventionalcommits';
}

const github = config.plugins?.find<PluginSpecSRGithub>(
  (p): p is PluginSpecSRGithub => p[0] === '@semantic-release/github',
);
if (github) {
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  github[1] ??= {} as PluginSpecSRGithub[1];
  github[1].releaseBodyTemplate = `${githubReleaseAssetHint}
  `;
}

export default config;
