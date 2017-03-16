#!/bin/bash
# Taken from https://github.com/docker/for-mac/issues/668#issuecomment-284028148

set -e
cd ~/Library/Containers/com.docker.docker/Data/database
git reset --hard

echo -n "Current full-sync-on-flush setting: "
cat ./com.docker.driver.amd64-linux/disk/full-sync-on-flush || echo "none"
echo

echo -n "Current on-flush setting: "
cat ./com.docker.driver.amd64-linux/disk/on-flush
echo

echo -n false > ./com.docker.driver.amd64-linux/disk/full-sync-on-flush
echo -n none > ./com.docker.driver.amd64-linux/disk/on-flush

git add ./com.docker.driver.amd64-linux/disk/full-sync-on-flush
git add ./com.docker.driver.amd64-linux/disk/on-flush
git commit -s -m "disable flushing"

echo "Docker should restart by itself now."
