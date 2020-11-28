#!/bin/sh

# This script will obtain a new GitLab Runner Token
# based on the registration token

#Author    :Karel Fiala
#Email     :fiala.karel@gmail.com
#Version   :v1.0.0
#Date      :20201128
#Usage     :wget -q https://raw.githubusercontent.com/fialakarel/scripts/master/gitlab/obtain-gitlab-runner-token.sh -O - | bash -

set -ef

log() {
    echo "[obtain-gitlab-runner-token.sh] ${*}"
}

log 'Please, provide GitLab Runner Registration Token'
read GITLAB_RUNNER_REGISTRATION_TOKEN

log 'Requesting GitLab Runner Token'
curl --request POST "https://gitlab.com/api/v4/runners" \
    --form "token=$GITLAB_RUNNER_REGISTRATION_TOKEN" \
    --form "description=My GitLab Runner"

echo

log 'Use the token above to launch your new GitLab Runner'