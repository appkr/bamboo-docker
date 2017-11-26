#!/bin/bash

AUTHOR_NAME=`git show --pretty=format:%an`
AUTHOR_EMAIL=`git show --pretty=format:%ae`
GIT_HASH=`git show --pretty=format:%H`
GIT_SUBJECT=`git show --pretty=format:%s`
GIT_BODY=`git show --pretty=format:%b`

echo "" >> build.txt
echo "BUILD_GIT_AUTHOR_NAME=$AUTHOR_NAME" >> build.txt
echo "BUILD_GIT_AUTHOR_EMAIL=$AUTHOR_EMAIL" >> build.txt
echo "BUILD_GIT_HASH=$GIT_HASH" >> build.txt
echo "BUILD_GIT_SUBJECT=$GIT_SUBJECT" >> build.txt
echo "BUILD_GIT_BODY=$GIT_BODY" >> build.txt

cp .env.example .env
php artisan key:generate
/usr/local/bin/composer install --no-progress --no-interaction -vvv
