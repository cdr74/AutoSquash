#!/bin/bash
set -e

## COLORS
SUCCESS="\e[32m" # GREEN COLOR
FAIL="\e[31m"    # RED COLOR
END="\e[0m"      # END COLOR

## SSL CONFIGURATION
## WARNING: Set the environment variables PATH_TO_KEYSTORE and KEYSTORE_PWD before running this script
SSL_PORT="server.port=9009"
SSL_KEY_STORE="server.ssl.key-store=${PATH_TO_KEYSTORE}/.keystore"
SSL_KEY_STORE_PASSWORD="server.ssl.key-store-password=${KEYSTORE_PWD}"
SSL_KEY_STORE_TYPE="server.ssl.keyStoreType=PKCS12"
SSL_KEY_SOTRE_KEYALIAS="server.ssl.keyAlias=tomcat"

BASE_DIR=$(pwd)

SQUASH_RELEASE="6.0.1"
SQUASH_PLUGIN_RELEASE="6.0.0"
SQUASH_REPOSITORY="https://nexus.squashtest.org/nexus/repository/public-releases/tm/core/squash-tm-distribution/"
OPEN_TELEMETRY_AGENT="https://github.com/open-telemetry/opentelemetry-java-instrumentation/releases/latest/download/opentelemetry-javaagent.jar"
PROMETHEUS_JMX_EXPORTER="https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_httpserver/0.20.0/jmx_prometheus_httpserver-0.20.0.jar"

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
echo $(printf "${SUCCESS} > Success - working directory created [$SQUASH_WORK_DIR] ${END}")


echo ""
echo "------------------------------------------------------------------------"
echo "2. Checking for existing remote release tarball - v${SQUASH_RELEASE}"
echo " > Expecting ${SQUASH_DOWNLOAD_FILE}..."
if [[ $(wget -S --spider $SQUASH_DOWNLOAD_FULL_URL 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then
  echo $(printf "${SUCCESS} > Success - Release file detected !${END}")
else
  echo $(printf "${FAIL} > Error - Release file not found !${END}")
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
# ---------- for faster TESTING copy local instead of wget -----------
cp /home/chris/dev/squash-tm-6.0.1.RELEASE.tar.gz $(pwd)
#wget -q --show-progress -N ${SQUASH_DOWNLOAD_FULL_URL}
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Release v${SQUASH_RELEASE} has been downloaded in $(pwd)${END}")
else
  echo $(printf "${FAIL} > Error - Download failed${END}")
  exit 1
fi


echo ""
echo "------------------------------------------------------------------------"
echo "4. Unpack & clean-up "
tar -xzf ${SQUASH_DOWNLOAD_FILE}
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Squash files are extracted in $(pwd)${END}")
else
  echo $(printf "${FAIL} > Error - ${SQUASH_DOWNLOAD_FILE} not found${END}")
  exit 1
fi
rm ${SQUASH_DOWNLOAD_FILE}
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Removed downloaded file ${SQUASH_DOWNLOAD_FILE} from $(pwd)${END}")
else
  echo $(printf "${FAIL} > Error - ${SQUASH_DOWNLOAD_FILE} not found${END}")
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
echo "6. Patch config files for Java opts and SSL use"
if ! [ -x "$(command -v jar)" ]; then
  echo $(printf "${FAIL} > Error - jar command is not available${END}")
  exit 1
fi
cd ${SQUASH_WORK_DIR}

cp ${BASE_DIR}/templates/SquashTM/bin/startup.sh ${SQUASH_DIR}/bin/
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Updated ${BASE_DIR}/templates/SquashTM/bin/startup.sh${END}")
else
  exit 1
fi

## ADD SSL
cp ${BASE_DIR}/templates/SquashTM/conf/squash.tm.cfg.properties ${SQUASH_DIR}/conf/
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Updated ${BASE_DIR}/templates/SquashTM/conf/squash.tm.cfg.properties${END}")
else
  exit 1
fi

echo $SSL_PORT >> ${SQUASH_DIR}/conf/squash.tm.cfg.properties
echo $SSL_KEY_STORE >> ${SQUASH_DIR}/conf/squash.tm.cfg.properties
echo $SSL_KEY_STORE_PASSWORD >> ${SQUASH_DIR}/conf/squash.tm.cfg.properties
echo $SSL_KEY_STORE_TYPE >> ${SQUASH_DIR}/conf/squash.tm.cfg.properties
echo $SSL_KEY_SOTRE_KEYALIAS >> ${SQUASH_DIR}/conf/squash.tm.cfg.properties


echo ""
echo "------------------------------------------------------------------------"
echo "7. Enable monitoring with OTEL agent (Open Telemetry) "
cd ${SQUASH_WORK_DIR}

if [[ $(wget -S --spider $OPEN_TELEMETRY_AGENT 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then
  echo $(printf "${SUCCESS} > Success - Telemetry agent file detected !${END}")
else
  echo $(printf "${FAIL} > Error - Telemetry agent file not found !${END}")
  exit 1
fi

wget -q --show-progress -N ${OPEN_TELEMETRY_AGENT}
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Telemetry agent has been downloaded !${END}")
else
  echo $(printf "${FAIL} > Error - Download failed!${END}")
  exit 1
fi

mv opentelemetry-javaagent.jar ${SQUASH_DIR}/bundles
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Telemetry agent set in ${SQUASH_DIR}/bundles${END}")
fi

if [[ $(wget -S --spider $PROMETHEUS_JMX_EXPORTER 2>&1 | grep 'HTTP/1.1 200 OK') ]]; then
  echo $(printf "${SUCCESS} > Success - JMX exporter file detected !${END}")
else
  echo $(printf "${FAIL} > Error - JMX exporter file not found !${END}")
  exit 1
fi

wget -q --show-progress -N "$PROMETHEUS_JMX_EXPORTER"
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - JMX exporter file has been downloaded !${END}")
else
  echo $(printf "${FAIL} > Error - Download failed!${END}")
  exit 1
fi

mv jmx_prometheus_httpserver-0.20.0.jar ${SQUASH_DIR}/bundles
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - JMX exporter set in ${SQUASH_DIR}/bundles${END}")
fi

cp ${BASE_DIR}/templates/SquashTM/conf/jmx_exporter_config.yaml ${SQUASH_DIR}/conf
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - JMX exporter config set in ${SQUASH_DIR}/conf${END}")
fi

# not the best place for this config, should be independent of squash
cp ${BASE_DIR}/templates/SquashTM/conf/collector-config.yaml ${SQUASH_DIR}/conf
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Otel collector config set in ${SQUASH_DIR}/conf${END}")
fi

# not the best place for this config, should be independent of squash
cp ${BASE_DIR}/templates/SquashTM/conf/prometheus.yml ${SQUASH_DIR}/conf
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Prometheus config set in ${SQUASH_DIR}/conf${END}")
fi


echo ""
echo "------------------------------------------------------------------------"
echo "8. Enable plugins"
cp ${SQUASH_DIR}/plugin-files/gitlab/bugtracker.gitlab-${SQUASH_PLUGIN_RELEASE}.RELEASE/plugins/bugtracker.gitlab-${SQUASH_PLUGIN_RELEASE}.RELEASE.jar ${SQUASH_DIR}/plugins
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Plugin: bugtracker.gitlab enabled${END}")
fi

cp ${SQUASH_DIR}/plugin-files/xsquash4gitlab/sync.xsquash4gitlab-${SQUASH_PLUGIN_RELEASE}.RELEASE/plugins/sync.xsquash4gitlab-${SQUASH_PLUGIN_RELEASE}.RELEASE.jar ${SQUASH_DIR}/plugins
if [ $? -eq 0 ]; then
  echo $(printf "${SUCCESS} > Success - Plugin: xsquash4gitlab enabled${END}")
fi

echo ""
echo $(printf "${SUCCESS}The setup is Ready !${END}")
echo "Use start_monitoring.sh before starting Squash"
echo "Go to ${SQUASH_DIR}/bin and run startup.sh for tests"
exit 0



echo ""
echo "------------------------------------------------------------------------"
echo "TODO - Package as Docker image"


echo ""
echo "------------------------------------------------------------------------"
echo "TODO - Cleanup work dir in [${SQUASH_WORK_DIR}]"
