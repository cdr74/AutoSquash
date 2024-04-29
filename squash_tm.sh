#!/bin/bash
set -e

SUCCESS="\e[32m" # GREEN COLOR
FAIL="\e[31m"    # RED COLOR
END="\e[0m"      # END COLOR 

BASE_DIR=$(pwd)

SQUASH_RELEASE="6.0.1"
SQUASH_REPOSITORY="https://nexus.squashtest.org/nexus/repository/public-releases/tm/core/squash-tm-distribution/"

SQUASH_WORK_DIR="${BASE_DIR}/SquashTM_work"
SQUASH_DIR="${SQUASH_WORK_DIR}/squash-tm"

SQUASH_DOWNLOAD_URL="${SQUASH_REPOSITORY}/${SQUASH_RELEASE}.RELEASE/"
SQUASH_DOWNLOAD_FILE="squash-tm-${SQUASH_RELEASE}.RELEASE.tar.gz"
SQUASH_DOWNLOAD_FULL_URL="${SQUASH_DOWNLOAD_URL}${SQUASH_DOWNLOAD_FILE}"

echo "########################################################################"
echo "#### SQUASH BUILD SCRIPT FOR ${SQUASH_DOWNLOAD_FILE}  "
echo "#### © Copyright 2024, Christian Räss & Xavier Oswald " 
echo "########################################################################"

echo ""
echo "------------------------------------------------------------------------"
echo "1. Preparing working directory [$SQUASH_WORK_DIR]"
if [ -d "${SQUASH_WORK_DIR}" ]; then rm -Rf ${SQUASH_WORK_DIR}; fi
mkdir ${SQUASH_WORK_DIR}
cd ${SQUASH_WORK_DIR}
echo  $(printf "${SUCCESS} > Success - working directory created [$SQUASH_WORK_DIR] ${END}")

echo ""
echo "------------------------------------------------------------------------"
echo "2. Checking for existing remote release tarball - v${SQUASH_RELEASE}"
echo " > Expecting ${SQUASH_DOWNLOAD_FILE}..."
if [[ `wget -S --spider $SQUASH_DOWNLOAD_FULL_URL 2>&1 | grep 'HTTP/1.1 200 OK'` ]]; then
  echo $(printf "${SUCCESS} > Success - Release file detected !${END}")
else
  echo $(printf "${FAIL} > Failure - Release file not found !${END}")
  exit 1
fi

## XAVIER,
## TODO: Build a checksum ? e.g. wget -O - http://example.com/myFile | tee myFile | md5sum > MD5SUM.
## OR CHECK IF VENDOR IS PROVIDING A CHECKSUM FILE

echo ""
echo "------------------------------------------------------------------------"
echo "3. Download release v${SQUASH_RELEASE}"
echo " > URL: ${SQUASH_DOWNLOAD_FULL_URL}"
echo " > Start dowloading..."
wget -q --show-progress -N ${SQUASH_DOWNLOAD_FULL_URL}
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Release v${SQUASH_RELEASE} has been downloaded in $(pwd)${END}")
else
  echo $(printf "${FAIL} > Failure - Download failed${END}")
  exit 1
fi

echo ""
echo "------------------------------------------------------------------------"
echo "4. Unpack & clean-up "
tar -xzf ${SQUASH_DOWNLOAD_FILE}
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Squash files are extracted in $(pwd)${END}")
else
  echo $(printf "${FAIL} > Failure - ${SQUASH_DOWNLOAD_FILE} not found${END}")
  exit 1
fi
rm ${SQUASH_DOWNLOAD_FILE}
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Removed download file ${SQUASH_DOWNLOAD_FILE} from $(pwd)${END}")
else
  echo $(printf "${FAIL} > Failure - ${SQUASH_DOWNLOAD_FILE} not found${END}")
  exit 1
fi
cd ${SQUASH_DIR}


echo ""
echo "------------------------------------------------------------------------"
echo "5. Remove windows specific files (exe, bat, maria db)"
find . -name "*.exe" -exec rm {} \;
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Removed all *.exe files in $(pwd)${END}")
else
  exit 1
fi
find . -name "*.bat" -exec rm {} \;
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Removed all *.bat files in $(pwd)${END}")
else
  exit 1
fi
find database-scripts -name "mariadb*" -exec rm {} \;
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Removed maria db files in $(pwd)${END}")
else
  exit 1
fi

## XAVIER
## TODO: Do we replace completly the files as it's being done ?
## OR we do a patch that we apply ?
## OR we dynamically change the files content by adding / changing what we miss ? 

echo ""
echo "------------------------------------------------------------------------"
echo "5. Patch config files for Java opts and SSL use"
cd ${SQUASH_WORK_DIR}
cp ${BASE_DIR}/templates/SquashTM/bin/startup.sh ${SQUASH_DIR}/bin/
mkdir war_patch
cd war_patch
cp ${SQUASH_DIR}/bundles/squash-tm.war .
jar -uf ./squash-tm.war -C ${BASE_DIR}/templates/SquashTM/war WEB-INF/classes/config/application.properties
cp ./squash-tm.war ${SQUASH_DIR}/bundles/squash-tm.war
cd ${SQUASH_WORK_DIR}
rm -rf war_patch

## XAVIER
## TODO: Download from GitHub might be restricted 
## Is Open-telemetry package available in our Nexus setup ?

echo ""
echo "------------------------------------------------------------------------"
echo "Enable monitoring with OTEL agent (if this works, let's close JMX port)"
cd ${SQUASH_WORK_DIR}
wget https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar
mv opentelemetry-javaagent.jar ${SQUASH_DIR}/bundles

# docker pull otel/opentelemetry-collector
# docker  run -p 4318:4318 -v /home/chris/dev/AutoSquash/templates/SquashTM/conf/collector-config.yaml otel/opentelemetry-collector:latest &
# docker pull prom/prometheus
# docker run -p 9090:9090 -v /home/chris/dev/AutoSquash/templates/SquashTM/conf/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus &

echo "Go to ${SQUASH_DIR}/bin and run startup.sh for tests"

echo ""
echo "------------------------------------------------------------------------"
echo "TODO - Package as Docker image"

echo ""
echo "------------------------------------------------------------------------"
echo "TODO - Cleanup work dir in [${SQUASH_WORK_DIR}]"
