#!/bin/sh -ex
# build the artifacts using the "pure" maven builds

cd ${WORKSPACE}/ranger
mvn versions:set -DnewVersion=${ARTIFACT_VERSION}
if [ "$RUN_UNIT_TESTS" == "true" ]; then
  mvn clean install assembly:assembly
else
  mvn -DskipTests clean install assembly:assembly
fi
