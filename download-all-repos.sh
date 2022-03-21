#!/bin/bash

# Clone all *public* github.com repositories for a specified user.
# https://kai-taylor.com/download-github-repos-for-user/

# 2022-03-20 modifications by rbeede to pull as well for already existing
# Updated as required for newer GitHub security changes

if [ $# -eq 0 ]
  then
    echo "Usage: $0 <user_name> "
    exit;
fi

USER=$1

TARGET_DIR=`pwd`

# clone all repositories for user specifed
for repo in `curl -s https://api.github.com/users/$USER/repos?per_page=1000 |grep clone_url |awk '{print $2}'| sed 's/"\(.*\)",/\1/'`;do
  cd $TARGET_DIR

  git clone $repo;

done;

for repo_dir in $TARGET_DIR/*; do
  echo "Refreshing $repo_dir"

  cd $repo_dir

  git pull
done;
