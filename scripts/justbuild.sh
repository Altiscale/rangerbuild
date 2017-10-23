#!/bin/sh -ex
# build the artifacts using the "pure" maven builds

cd ${WORKSPACE}/hadoop-lzo
mvn versions:set -DnewVersion=0.4.18-${DATE_STRING}
if [ "$RUN_UNIT_TESTS" == "true" ]; then
  mvn clean package
else
  mvn clean package -DskipTests
fi

cd ${WORKSPACE}/hadoop
mvn versions:set -DnewVersion=${ARTIFACT_VERSION}
if [ "$RUN_UNIT_TESTS" == "true" ]; then
  mvn -Pdist,docs,src,native --fail-never -Dtar -Dbundle.snappy  -Dsnappy.lib=/usr/lib64 -Drequire.fuse=true -Drequire.snappy -Dcontainer-executor.conf.dir=/etc/hadoop clean install
else
  mvn -Pdist,docs,src,native -Dtar -DskipTests -Dbundle.snappy -Dsnappy.lib=/usr/lib64 -Drequire.fuse=true -Drequire.snappy -Dcontainer-executor.conf.dir=/etc/hadoop clean install
fi
