#!/bin/bash

if [ "$TRAVIS_REPO_SLUG" == "cstockloew/platform" ] && [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_BRANCH" == "master" ]; then

  echo -e "Publishing...\n"

  cp -R "target/site/apidocs" $HOME/javadoc-latest

  cd $HOME
  git config --global user.email "stockloew@gmx.de"
  git config --global user.name "cstockloew"
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/cstockloew/platform gh-pages > /dev/null

  cd gh-pages
  git rm -rf ./javadoc
  cp -Rf $HOME/javadoc-latest ./javadoc
  git add -f .
  git commit -m "Latest javadoc on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"
  git push -fq origin gh-pages > /dev/null

  echo -e "Published Javadoc to gh-pages.\n"
  
fi

