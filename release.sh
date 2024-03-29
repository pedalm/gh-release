#!/bin/bash
set -e

# Helpers for echo
bold=$(tput bold)
normal=$(tput sgr0)
echo ""

## Ensure latest main
echo "> Checking out the latest main"
git checkout main &> /dev/null && git pull > /dev/null

## Check if tags exist, otherwise assume this is the very first tag and take all the commit history
echo "> Generating changelog"

if (git describe --tags --abbrev=0 > /dev/null 2>&1); then
    lastReleaseVersion=$(git describe --tags --abbrev=0)
    changelog=$(git log --pretty="%h - %s (%an)" "$lastReleaseVersion"..HEAD)
else
    lastReleaseVersion="-none-"
    changelog=$(git log --pretty="%h - %s (%an)" HEAD)
fi

echo ""
printf "  ${bold}version${normal} (curr: ${bold}$lastReleaseVersion${normal}): "; read newVersion
printf "  ${bold}description${normal}: "; read description
echo ""

## Get the release template
BASEDIR=$(dirname $0)
template=$(<${BASEDIR}/.github/RELEASE_TEMPLATE.md)

## Get the repository's URL
repositoryUrl=$(git config --get remote.origin.url)
repositoryUrl=${repositoryUrl//"git@"/"https://"}
repositoryUrl=${repositoryUrl//"github.com:"/"github.com/"}
repositoryUrl=${repositoryUrl//".git"/""}

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
