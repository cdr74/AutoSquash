#! /bin/sh
#
#     This file is part of the Squashtest platform.
#     Copyright (C) Henix, henix.fr
#
#     See the NOTICE file distributed with this work for additional
#     information regarding copyright ownership.
#
#     This is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     this software is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with this software.  If not, see <http://www.gnu.org/licenses/>.
#

#That script will :
#- check that the java environnement exists,
#- the version is adequate,
#- will run the application

#####################################################################################################
# !!! IF YOU MAKE ANY CHANGES TO THIS FILE, UPDATE THE install-script.sh FILE OF DOCKER PROJECT !!! #
#####################################################################################################

# Default variables
JAR_NAME="squash-tm.war"                   # Java main library
# CR: unused, overwritten by application.properties in the war file
#HTTPS_PORT=8080                               # Port for HTTP connector (default 8080; disable with -1)
# Directory variables
TMP_DIR=../tmp                             # Tmp and work directory
BUNDLES_DIR=../bundles                     # Bundles directory
CONF_DIR=../conf                           # Configurations directory
LOG_DIR=../logs                            # Log directory
TOMCAT_HOME=../tomcat-home                 # Tomcat home directory
PLUGINS_DIR=../plugins                     # Plugins directory
# DataBase parameters
DB_TYPE=h2                                 # Database type, one of h2, mariadb, postgresql
DB_URL="jdbc:h2:../data/squash-tm;NON_KEYWORDS=ROW,VALUE"           # DataBase URL
DB_USERNAME=sa                              # Database username
DB_PASSWORD=sa                              # DataBase password

## Do not configure a third digit here
REQUIRED_VERSION=17
# Extra Java args 
# CR: enabling G1, use 8GB for prod use, also use GC logging
JAVA_ARGS="-Xms2048m -Xmx2048m -XX:+UseG1GC"

# CR: enabling JMX, use ssl and authentication for prod
CATALINA_OPTS="-Dcom.sun.management.jmxremote.port=9099 -Dcom.sun.management.jmxremote.rmi.port=9099 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"


# Tests if java exists
echo -n "$0 : checking java environment... ";

java_exists=`java -version 2>&1`;

if [ $? -eq 127 ]
then
    echo;
    echo "$0 : Error : java not found. Please ensure that java is installed in \$PATH";
    exit -1;
fi

echo "done";

# Create logs and tmp directories if necessary
if [ ! -e "$LOG_DIR" ]; then
    mkdir $LOG_DIR
fi

if [ ! -e "$TMP_DIR" ]; then
    mkdir $TMP_DIR
fi

# Tests if the version is high enough
echo -n "checking version... ";

NUMERIC_REQUIRED_VERSION=`echo $REQUIRED_VERSION |sed 's/\./0/g'`;
java_version=`echo $java_exists | grep version |cut -d " " -f 3  |sed 's/\"//g' | cut -d "." -f 1,2 | sed 's/\./0/g'`;

if [ $java_version -lt $NUMERIC_REQUIRED_VERSION ]
then
    echo;
    echo "$0 : Error : your JRE does not meet the requirements. Please install a new JRE, required version ${REQUIRED_VERSION}.";
    exit -2;
fi

echo  "done";


# Let's go !
echo "$0 : starting Squash TM... ";

# CR: remove server.port as we set it in applications.properties inside the warfile
export APP_OPTS="-Dspring.datasource.url=${DB_URL} -Dspring.datasource.username=${DB_USERNAME} -Dspring.datasource.password=${DB_PASSWORD} -Duser.language=en"
DAEMON_ARGS="${JAVA_ARGS} ${APP_OPTS} -Djava.io.tmpdir=${TMP_DIR} -Dlogging.dir=${LOG_DIR} -jar ${BUNDLES_DIR}/${JAR_NAME} --spring.profiles.active=${DB_TYPE} --spring.config.additional-location=${CONF_DIR}/ --spring.config.name=application,squash.tm.cfg --logging.config=${CONF_DIR}/log4j2.xml --squash.path.bundles-path=${BUNDLES_DIR} --squash.path.plugins-path=${PLUGINS_DIR} --server.tomcat.basedir=${TOMCAT_HOME} "

#CR: add CATALINA_OPTS to start command
DAEMON_ARGS="${DAEMON_ARGS} ${CATALINA_OPTS}"



exec java ${DAEMON_ARGS}

