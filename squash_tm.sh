#!/usr/bin/bash

BASE_DIR=`pwd`
SQUASH_WORK_DIR="$BASE_DIR/SquashTM_work"
SQUASH_DIR="${SQUASH_WORK_DIR}/squash-tm"
SQUASH_DOWNLOAD_URL="https://nexus.squashtest.org/nexus/repository/public-releases/tm/core/squash-tm-distribution/6.0.1.RELEASE/"
SQUASH_DOWNLOAD_FILE="squash-tm-6.0.1.RELEASE.tar.gz"


echo ""
echo "------------------------------------------------------------------------"
echo "Preparing work dir in [$SQUASH_WORK_DIR]"
if [ -d "${SQUASH_WORK_DIR}" ]; then rm -Rf ${SQUASH_WORK_DIR}; fi
mkdir ${SQUASH_WORK_DIR}
cd ${SQUASH_WORK_DIR}


echo ""
echo "------------------------------------------------------------------------"
echo "Download release [${SQUASH_DOWNLOAD_URL}${SQUASH_DOWNLOAD_FILE}]"
wget "${SQUASH_DOWNLOAD_URL}${SQUASH_DOWNLOAD_FILE}"


echo ""
echo "------------------------------------------------------------------------"
echo "Unpack download ... and delete download"
tar -xvzf ${SQUASH_DOWNLOAD_FILE}
rm ${SQUASH_DOWNLOAD_FILE}
cd ${SQUASH_DIR}


echo ""
echo "------------------------------------------------------------------------"
echo "Remove windows specific files (exe, bat, maria db)"
find . -name "*.exe" -exec rm {} \;
find . -name "*.bat" -exec rm {} \;
find database-scripts -name "mariadb*" -exec rm {} \;


echo ""
echo "------------------------------------------------------------------------"
echo "Patch config files for Java opts and SSL use"
cd ${SQUASH_WORK_DIR}
cp ${BASE_DIR}/templates/SquashTM/bin/startup.sh ${SQUASH_DIR}/bin/
mkdir war_patch
cd war_patch
cp ${SQUASH_DIR}/bundles/squash-tm.war .
jar -uf ./squash-tm.war -C ${BASE_DIR}/templates/SquashTM/war WEB-INF/classes/config/application.properties
cp ./squash-tm.war ${SQUASH_DIR}/bundles/squash-tm.war
cd ${SQUASH_WORK_DIR}
rm -rf war_patch


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


