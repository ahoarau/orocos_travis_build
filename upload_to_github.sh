#!/bin/sh

tar -czf ~/orocos_toolchain-release.tar.gz ~/orocos-2.9_ws/install

git config --global user.email "hoarau.robotics@gmail.com"
git config --global user.name "Antoine Hoarau - Travis-CI"

git clone https://ahoarau:$1@github.com/ahoarau/orocos_travis_build
cd orocos_travis_build
git checkout -q -b $(lsb_release -cs)-release
cp ~/orocos_toolchain-release.tar.gz .
git add ~/orocos_toolchain-release.tar.gz
git commit -m "Travis-CI build $(date)"
git push -q -f origin $(lsb_release -cs)-release

#curl --data '{"tag_name": "v2.9.0","target_commitish": "master","name": "v2.9.0","body": "Release of version 2.9.0","draft": false,"prerelease": false}' https://api.github.com/repos/:ahoarau/:orocos_travis_build/releases?access_token=:$API_TOKEN
