pipeline {
  agent any
  stages {
    stage('build') {
      steps {
        sh '''echo "HOME: $HOME"
export DOCKER_BASE_IMAGE_NAME=docker-dev.artifactory.service.altiscale.com/hadoopbase
export PATCH_DIR="dev_images/docker"
export ALTISCALE_RELEASE=4.6.0
export PACKAGE_NAME=ranger
export RANGER_VERSION=0.7.1
export PACKAGE_BRANCH=branch-0.7.1-alti
export BUILD_BRANCH=branch-0.7.1-alti

/bin/bash ${PATCH_DIR}/package_build/patch.sh'''
      }
    }
  }
}