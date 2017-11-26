#!/bin/bash

# ------------------------------------------------------------------------------
# Install Composer
# ------------------------------------------------------------------------------

# php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
# php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
# php composer-setup.php
# php -r "unlink('composer-setup.php');"

# php composer.phar self-update

# ------------------------------------------------------------------------------
# Update Github Branch Status
# ------------------------------------------------------------------------------

REPO_URL=${bamboo.planRepository.1.repositoryUrl}
[[ $REPO_URL =~ github.com\/(.*).git ]]
STATUS_UPDATE_URL="https://api.github.com/repos/${BASH_REMATCH[1]}/statuses/${bamboo.repository.revision.number}"
curl -H "Authorization: token ${bamboo_PERSONAL_ACCESS_TOKEN}" --request POST --data '{"state": "pending", "context": "bamboo/build", "description": "Bamboo build is running", "target_url": "${bamboo.buildResultsUrl}"}' $STATUS_UPDATE_URL
