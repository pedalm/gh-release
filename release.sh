#!/bin/bash
set -e

### Edit the following according to your repository
repositoryUrl="https://github.com/pedalm/gh-release"

# Helpers for echo
bold=$(tput bold)
normal=$(tput sgr0)
echo ""

## Ensure latest master
echo "> Checking out the latest master"
git checkout master &> /dev/null && git pull > /dev/null

## Ensure latest changelog
echo "> Generating changelog"
changelog=$(git log --pretty="%h - %s (%an)" "$(git describe --tags --abbrev=0)"..HEAD)

## Get latest tag
lastReleaseVersion=$(git describe --tags --abbrev=0)

echo ""
printf "  ${bold}version${normal} (curr: ${bold}$lastReleaseVersion${normal}): "; read newVersion
printf "  ${bold}description${normal}: "; read description
echo ""

## Get the release template
template=$(<./.github/RELEASE_TEMPLATE.md)

## Replace appropriate variables
template=${template//"#DESCRIPTION#"/$description}
template=${template//"#LATEST_VERSION#"/$lastReleaseVersion}
template=${template//"#NEW_VERSION#"/$newVersion}
template=${template//"#REPOSITORY_URL#"/$repositoryUrl}
## Append changelog
template+="
$changelog"

## Create Github release
printf "> Creating ${bold}$newVersion${normal} in Github\n\n"
gh release create $newVersion -d -n "$template" -t $newVersion > /dev/null
gh release view $newVersion -w > /dev/null
