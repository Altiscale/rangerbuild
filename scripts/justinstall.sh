#!/bin/sh -ex
ALTISCALE_RELEASE=${ALTISCALE_RELEASE:-0.1.0}
RPM_DESCRIPTION="Apache Ranger ${ARTIFACT_VERSION}\n\n${DESCRIPTION}"

# convert the tarball into an RPM
#create the installation directory (to stage artifacts)
mkdir -p --mode 0755 ${INSTALL_DIR}

OPT_DIR=${INSTALL_DIR}/opt/ranger-${ARTIFACT_VERSION}
mkdir --mode=0755 -p ${OPT_DIR}
cd ${OPT_DIR}

ls ${WORKSPACE}/ranger/target/ranger-${ARTIFACT_VERSION}*.tar.gz | xargs -I{} tar -xvzpf {}
chmod 755 ${OPT_DIR}

ETC_DIR=${INSTALL_DIR}/etc/ranger-${ARTIFACT_VERSION}
mkdir --mode=0755 -p ${ETC_DIR}
## move the config directory to /etc
#cp -rp ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/etc/hadoop/* $ETC_DIR
#mv ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/etc/hadoop ${OPT_DIR}/hadoop-${ARTIFACT_VERSION}/etc/hadoop-templates

# Add init.d scripts and sysconfig
mkdir --mode=0755 -p ${INSTALL_DIR}/etc/rc.d/init.d
cp ${WORKSPACE}/etc/init.d/* ${INSTALL_DIR}/etc/rc.d/init.d
mkdir --mode=0755 -p ${INSTALL_DIR}/etc/sysconfig
cp ${WORKSPACE}/etc/sysconfig/* ${INSTALL_DIR}/etc/sysconfig

# Add executables
mkdir --mode=0755 -p ${INSTALL_DIR}/usr/bin
cp ${WORKSPACE}/usr/bin/ranger-admin ${INSTALL_DIR}/usr/bin/

cd ${INSTALL_DIR}

# All config files:
export CONFIG_FILES="--config-files /etc/ranger-${ARTIFACT_VERSION} "


cd ${RPM_DIR}

export RPM_NAME=`echo alti-ranger-${ARTIFACT_VERSION}`
fpm --verbose \
--maintainer support@altiscale.com \
--vendor Altiscale \
--provides ${RPM_NAME} \
--url ${GITREPO} \
--license "Apache License v2" \
-s dir \
-t rpm \
-n ${RPM_NAME}  \
-v ${ALTISCALE_RELEASE} \
--iteration ${DATE_STRING} \
--description "${RPM_DESCRIPTION}" \
${CONFIG_FILES} \
--rpm-attr 755,root,root:/etc/rc.d/init.d/ranger_admin \
--rpm-user hadoop \
--rpm-group hadoop \
-C ${INSTALL_DIR} \
opt etc usr
