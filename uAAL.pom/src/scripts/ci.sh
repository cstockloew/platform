#!/bin/bash

if [ "$TRAVIS_REPO_SLUG" != "$MY_REPO" ] || [ "$TRAVIS_PULL_REQUEST" != "false" ] || [ "$TRAVIS_BRANCH" != "master" ]; then
  exit 1
fi

# stop on error
set -e
#show commands
set -x

publish_site() {
  echo -e "Publishing...\n"

#  cp -R "target/site" $HOME/site
    
  cd $HOME
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "travis-ci"
  git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/${MY_REPO} gh-pages > /dev/null

  cd gh-pages
  git rm -rf ./site > /dev/null
  cp -Rf $HOME/site ./site
  git add -f . > /dev/null
  git commit -m "Latest site on successful travis build $TRAVIS_BUILD_NUMBER auto-pushed to gh-pages"  > /dev/null
  git push -fq origin gh-pages > /dev/null

  echo -e "Published site to gh-pages.\n"
}

do_script() {
  echo -e "do_script"
  free -m
#  echo "---------- 
  ((((mvn clean install -DskipTests -Dorg.ops4j.pax.logging.DefaultServiceLog.level=WARN; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
#  ((((mvn javadoc:javadoc -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
# - ((((mvn surefire-report:report -Dsurefire-report.aggregate=true -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
  ((((mvn javadoc:aggregate -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
  ((((mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=xml -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
  ((((mvn cobertura:cobertura -Dcobertura.aggregate=true -Dcobertura.report.format=html -DskipTests -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
  ((((mvn surefire-report:report -Dsurefire-report.aggregate=true -fae; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
  ((((mvn site:site -DskipTests -Dcobertura.skip -Dmaven.javadoc.skip=true -Duaal.report=ci-repo -fn -e; echo $? >&3) | grep -i "INFO] Build" >&4) 3>&1) | (read xs; exit $xs)) 4>&1
  mvn site:stage -DstagingDirectory=$HOME/site/mw.pom -fn
}

do_success() {
  echo -e "do_success"
  mvn deploy -DskipTests -DaltDeploymentRepository=uaal-nightly::default::http://depot.universaal.org/maven-repo/nightly/
  publish_site
  export GH_TOKEN="deleted"
  export NIGHTLY_PASSWORD="deleted"
  export NIGHTLY_USERNAME="deleted"
  mvn org.eluder.coveralls:coveralls-maven-plugin:4.3.0:report -e
  bash <(curl -s https://codecov.io/bash)
}

echo -e "select"
if [ "$1" == "script" ]; then
  do_script
fi

if [ "$1" == "success" ]; then
  do_success
fi
echo -e "end"


