# Copyright 2026 Noah Sherwin
# SPDX-License-Identifier: GPL-3.0-only

cmake_minimum_required(VERSION 3.19.0)

execute_process(COMMAND dotnet tool restore)
execute_process(COMMAND dotnet gitversion OUTPUT_VARIABLE GITVERSION_JSON)
message(VERBOSE ${GITVERSION_JSON})

# {
# "AssemblySemFileVer": "1.0.6.0",
# "AssemblySemVer": "1.0.6.0",
# "BranchName": "develop",
# "BuildMetaData": null,
# "CommitDate": "2026-09-11",
# "CommitsSinceVersionSource": 157,
# "EscapedBranchName": "develop",
# "FullBuildMetaData": "Branch.develop.Sha.f630782ff0834e839a99c3f1872520a5f71026c6",
# "FullSemVer": "1.0.6-alpha.157",
# "InformationalVersion": "1.0.6-alpha.157+Branch.develop.Sha.f630782ff0834e839a99c3f1872520a5f71026c6",
# "Major": 1,
# "MajorMinorPatch": "1.0.6",
# "Minor": 0,
# "Patch": 6,
# "PreReleaseLabel": "alpha",
# "PreReleaseLabelWithDash": "-alpha",
# "PreReleaseNumber": 157,
# "PreReleaseTag": "alpha.157",
# "PreReleaseTagWithDash": "-alpha.157",
# "SemVer": "1.0.6-alpha.157",
# "Sha": "f630782ff0834e839a99c3f1872520a5f71026c6",
# "ShortSha": "f630782",
# "UncommittedChanges": 25,
# "VersionSourceDistance": 157,
# "VersionSourceIncrement": "None",
# "VersionSourceSemVer": "1.0.5",
# "VersionSourceSha": "bedb3fc916b126b051db7950feb123be61c7516b",
# "WeightedPreReleaseNumber": 157
# }
string(JSON GITVERSION_AssemblySemFileVer GET ${GITVERSION_JSON} AssemblySemFileVer)
string(JSON GITVERSION_AssemblySemVer GET ${GITVERSION_JSON} AssemblySemVer)
string(JSON GITVERSION_BranchName GET ${GITVERSION_JSON} BranchName)
string(JSON GITVERSION_BuildMetaData GET ${GITVERSION_JSON} BuildMetaData)
string(JSON GITVERSION_CommitDate GET ${GITVERSION_JSON} CommitDate)
string(JSON GITVERSION_CommitsSinceVersionSource GET ${GITVERSION_JSON} CommitsSinceVersionSource)
string(JSON GITVERSION_EscapedBranchName GET ${GITVERSION_JSON} EscapedBranchName)
string(JSON GITVERSION_FullBuildMetaData GET ${GITVERSION_JSON} FullBuildMetaData)
string(JSON GITVERSION_FullSemVer GET ${GITVERSION_JSON} FullSemVer)
string(JSON GITVERSION_InformationalVersion GET ${GITVERSION_JSON} InformationalVersion)
string(JSON GITVERSION_Major GET ${GITVERSION_JSON} Major)
string(JSON GITVERSION_MajorMinorPatch GET ${GITVERSION_JSON} MajorMinorPatch)
string(JSON GITVERSION_Minor GET ${GITVERSION_JSON} Minor)
string(JSON GITVERSION_Patch GET ${GITVERSION_JSON} Patch)
string(JSON GITVERSION_PreReleaseLabel GET ${GITVERSION_JSON} PreReleaseLabel)
string(JSON GITVERSION_PreReleaseLabelWithDash GET ${GITVERSION_JSON} PreReleaseLabelWithDash)
string(JSON GITVERSION_PreReleaseNumber GET ${GITVERSION_JSON} PreReleaseNumber)
string(JSON GITVERSION_PreReleaseTag GET ${GITVERSION_JSON} PreReleaseTag)
string(JSON GITVERSION_PreReleaseTagWithDash GET ${GITVERSION_JSON} PreReleaseTagWithDash)
string(JSON GITVERSION_SemVer GET ${GITVERSION_JSON} SemVer)
string(JSON GITVERSION_Sha GET ${GITVERSION_JSON} Sha)
string(JSON GITVERSION_ShortSha GET ${GITVERSION_JSON} ShortSha)
string(JSON GITVERSION_UncommittedChanges GET ${GITVERSION_JSON} UncommittedChanges)
string(JSON GITVERSION_VersionSourceDistance GET ${GITVERSION_JSON} VersionSourceDistance)
string(JSON GITVERSION_VersionSourceIncrement GET ${GITVERSION_JSON} VersionSourceIncrement)
string(JSON GITVERSION_VersionSourceSemVer GET ${GITVERSION_JSON} VersionSourceSemVer)
string(JSON GITVERSION_VersionSourceSha GET ${GITVERSION_JSON} VersionSourceSha)
string(JSON GITVERSION_WeightedPreReleaseNumber GET ${GITVERSION_JSON} WeightedPreReleaseNumber)
