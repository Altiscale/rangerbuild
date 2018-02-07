#!/bin/sh -ex
ALTISCALE_RELEASE=${ALTISCALE_RELEASE:-0.1.0}
RPM_DESCRIPTION="Apache Ranger ${ARTIFACT_VERSION}\n\n${DESCRIPTION}"

# convert the tarball into an RPM
#create the installation directory (to stage artifacts)
mkdir -p --mode 0755 ${INSTALL_DIR}

OPT_DIR=${INSTALL_DIR}/opt
mkdir --mode=0755 -p ${OPT_DIR}
cd ${OPT_DIR}

tar -xvzpf ${WORKSPACE}/hadoop/hadoop-dist/target/hadoop-${ARTIFACT_VERSION}.tar.gz
chmod 755 ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}
# https://verticloud.atlassian.net/browse/OPS-731
# create /etc/hadoop, in a future version of the build we may move the config there directly
ETC_DIR=${INSTALL_DIR}/etc/hadoop-${ARTIFACT_VERSION}
mkdir --mode=0755 -p ${ETC_DIR}
# move the config directory to /etc
cp -rp ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/etc/hadoop/* $ETC_DIR
mv ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/etc/hadoop ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/etc/hadoop-templates

# Add init.d scripts and sysconfig
mkdir --mode=0755 -p ${INSTALL_DIR}/etc/rc.d/init.d
cp ${WORKSPACE}/etc/init.d/* ${INSTALL_DIR}/etc/rc.d/init.d
mkdir --mode=0755 -p ${INSTALL_DIR}/etc/sysconfig
cp ${WORKSPACE}/etc/sysconfig/* ${INSTALL_DIR}/etc/sysconfig

# Add executables
mkdir --mode=0755 -p ${INSTALL_DIR}/usr/bin
cp ${WORKSPACE}/usr/bin/ranger-admin ${INSTALL_DIR}/usr/bin/

cd ${INSTALL_DIR}

#interleave lzo jars
for i in share/hadoop/mapreduce/lib share/hadoop/yarn/lib share/hadoop/common/lib; do
  cp -rp ${WORKSPACE}/hadoop-lzo/target/hadoop-lzo-[0-9]*.[0-9]*.[0-9]*-[0-9]*[0-9].jar ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/$i
done
cp -P ${WORKSPACE}/hadoop-lzo/target/native/Linux-amd64-64/lib/libgplcompression.* ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/lib/native/

# Fix all permissions
chmod 755 ${INSTALL_DIR}/opt/hadoop-${ARTIFACT_VERSION}/sbin/*.sh
chmod 755 ${INSTALL_DIR}/opt/hadoop-${ARTIFACT_VERSION}/sbin/*.cmd

# All config files:
export CONFIG_FILES="--config-files /etc/hadoop-${ARTIFACT_VERSION} \
  --config-files /etc/sysconfig "

cd ${RPM_DIR}

export RPM_NAME=`echo alti-hadoop-${ARTIFACT_VERSION}`
fpm --verbose \
--maintainer support@altiscale.com \
--vendor Altiscale \
--provides ${RPM_NAME} \
--provides "libhdfs.so.0.0.0()(64bit)" \
--provides "libhdfs(x86-64)" \
--provides libhdfs \
--replaces alti-hadoop \
--depends 'lzo > 2.0' \
--url ${GITREPO} \
--license "Apache License v2" \
-s dir \
-t rpm \
-n ${RPM_NAME}  \
-v ${ALTISCALE_RELEASE} \
--iteration ${DATE_STRING} \
--description "${RPM_DESCRIPTION}" \
${CONFIG_FILES} \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_journalnode \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_datanode \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_historyserver \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_namenode \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_nodemanager \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_resourcemanager \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_secondarynamenode \
--rpm-attr 644,root,root:/etc/sysconfig/hadoop_timelineserver \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_datanode \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_historyserver \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_httpfs \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_journalnode \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_namenode \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_nodemanager \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_resourcemanager \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_secondarynamenode \
--rpm-attr 755,root,root:/etc/rc.d/init.d/hadoop_timelineserver \
--rpm-user hadoop \
--rpm-group hadoop \
-C ${INSTALL_DIR} \
opt etc usr
