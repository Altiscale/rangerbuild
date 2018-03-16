#!/bin/sh -ex
# build the artifacts using the "pure" maven builds

cd ${WORKSPACE}/ranger

if [ "$RUN_SOURCECLEAR_SCAN" == "true" ]; then
  curl -sSL https://download.sourceclear.com/ci.sh | DEBUG=1 sh -s -- scan  --no-upload
fi

echo "Before mvn command - Directory Structure"
ls -l
mvn versions:set -DnewVersion=${ARTIFACT_VERSION}
if [ "$RUN_UNIT_TESTS" == "true" ]; then
  mvn ${JUSTBUILD_EXTRA_OPTS} clean install assembly:assembly 
else
  mvn ${JUSTBUILD_EXTRA_OPTS} -DskipTests clean install assembly:assembly 
fi

ls -l
echo "After mvn command - Directory Structure"
ls -l
