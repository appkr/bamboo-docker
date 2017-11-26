#!/bin/bash

rm .env

# ------------------------------------------------------------------------------
# Update Github Branch Status
# ------------------------------------------------------------------------------

TEST_RESULTS_PATH="test-reports/*.xml"

cd ${bamboo.build.working.directory}
REPO_URL=${bamboo.planRepository.1.repositoryUrl}
[[ $REPO_URL =~ github.com\/(.*).git ]]
STATUS_UPDATE_URL="https://api.github.com/repos/${BASH_REMATCH[1]}/statuses/${bamboo.repository.revision.number}"

if ls $TEST_RESULTS_PATH 1> /dev/null 2>&1; then
  curl -H "Authorization: token ${bamboo_PERSONAL_ACCESS_TOKEN}" --request POST --data '{"state": "success", "context": "bamboo/build", "description": "Bamboo build Completed!", "target_url": "${bamboo.buildResultsUrl}"}' $STATUS_UPDATE_URL > /dev/null
else
  curl -H "Authorization: token ${bamboo_PERSONAL_ACCESS_TOKEN}" --request POST --data '{"state": "failure", "context": "bamboo/build", "description": "Bamboo build Failed!", "target_url": "${bamboo.buildResultsUrl}"}' $STATUS_UPDATE_URL > /dev/null
fi
##check for test failures.
if (grep '<failure' $TEST_RESULTS_PATH 1> /dev/null 2>&1) then
  failures=$(grep '<failure' $TEST_RESULTS_PATH | wc -l)
  curl -H "Authorization: token ${bamboo_PERSONAL_ACCESS_TOKEN}" --request POST --data '{"state": "failure", "context": "bamboo/tests", "description": "'"${failures}"' Test(s) failed!", "target_url": "${bamboo.buildResultsUrl}"}' $STATUS_UPDATE_URL > /dev/null
else
  curl -H "Authorization: token ${bamboo_PERSONAL_ACCESS_TOKEN}" --request POST --data '{"state": "success", "context": "bamboo/tests", "description": "Tests Passed", "target_url": "${bamboo.buildResultsUrl}"}' $STATUS_UPDATE_URL > /dev/null
fi

# ------------------------------------------------------------------------------
# Ceeate Artifact
# ------------------------------------------------------------------------------

# 패키지 생성시, .ebignore에서 제외할 파일/폴더를 설정하고 있다.
if [ -f .ebignore ]; then
  cp .ebignore .gitignore
fi

# Raygun Deployment 생성 스크립트 중 git 사용이 있지만
#   배포 패키지에 .git을 포함하지 않아 제외한다.
if [ -f .ebextensions/04raygun-deployment.config ]; then
  rm .ebextensions/04raygun-deployment.config;
fi

git config core.autocrlf false
# 원래 .gitignore가 아닌 .ebignore로 대체한 상태를 stash
#   커맨드를 이용해 임시 커밋을 만들어 git archive 로 패키징
git add --all .
uploadStash=`git stash create`
git archive -o $bamboo_BUILD_FILENAME ${uploadStash:-HEAD}

git reset HEAD -- .ebignore .gitignore
git checkout HEAD -- .ebignore .gitignore

# 기존 .ebignore 파일을 패키지 파일에 복원
if [ -f .ebignore ]; then
  zip $bamboo_BUILD_FILENAME .ebignore
fi

# 기존 .gitignore 파일을 패키지 파일에 복원
if [ -f .gitignore ]; then
  zip $bamboo_BUILD_FILENAME .gitignore
fi

# ------------------------------------------------------------------------------
# Add .git Folder to Artifact
# ------------------------------------------------------------------------------

# The current ElasticBeanstalk deploy scripts provided in .ebextensions require the git repository to be present in the final build.
# Since Bamboo uses "--reference" when cloning the repository into the plan directory,
#   we must repack so that alternate object references are copied to the local repository before packing.
# Otherwise, a git reference error will occur in the package for git operations. For example:
#
# error: object directory /home/bamboo/bamboo-home/xml-data/build-dir/_git-repositories-cache/c7142083930e48ce04da8f8c9a0aeab225b3f188/.git/objects does not exist; check .git/objects/info/alternates. fatal: bad object HEAD. Hook /opt/elasticbeanstalk/hooks/appdeploy/post/610-report_raygun_deployment.sh failed.
git repack -a -d

zip -rq $bamboo_BUILD_FILENAME .git