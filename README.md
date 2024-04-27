# AutoSquash

Automate the process to download Squash TM and Orchestrator from official distribution, patch for secure and scalable operation, repackage for operations.

The idea is to keep pprod grade config files and an automation scipt in this repo; but not to replicate any assets from Squash side. 

_Caution_: there are multiple sources of old verions on bitbucket, github etc!


## Squash TM

Squash TM is a Spring Boot based app with integrated Tomcat v9. Our goal to run at prod scale is
- (done) Set proper GC param in tomcat start script 
- (done) Disable http and enforce https
- (done, not tested) Enable JMX for monitoring in startup script (do we also add a otel agent for tomcat?)
- Working on OTEL agent as alternative to JMX (security as well as data quality reasons)
- Set a proper connector for large scale in server.xml
- Do we need to enforce log rotation?
- Do we want to put this in Docker right away (we should, but that needs we also want to add liveness probes)?

We start with a pre-built package: https://nexus.squashtest.org/nexus/#browse/browse:public-releases
... alternative is start from source in: https://gitlab.com/henixdevelopment/open-source/squash
... current maintenance branch is "maintenance-6.x", in case we want to compile by ourselfes
... main Squash repository https://gitlab.com/henixdevelopment/open-source/squash/squashtest-tm-staging.git

SquashTM installation instructions are found here: 
https://henixdevelopment.gitlab.io/squash/doc/squashtm-doc-en/v3/install-guide/install-squash/install-squash.html


Key config file (we should ask Hennix for good defaults)
- bin/squash-tm.xml      _XXX WHAT IS THIS XXX_
- bin/startup.sh 
- conf/squash.tm.cfg-postgresql.properties 
- conf/log4j2.xml 
- WEB-INF/classes/config/application.properties     # this is inside the war file

We keep a copy of the config files we modify in templates and copy them over what comes from the download.
All changes are commented with "# CR:"

Configuring the server for certificate use (to support ssl), eg adding keystore is not covered in the script. 
Checkout: https://tomcat.apache.org/tomcat-9.0-doc/ssl-howto.html 

Manual steps to perform once for local tests are 
`
 $JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA
`


Testing the app locally, go to bin directury 
1. docker run -p 9090:9090 prom/prometheus &
2. ./startup.sh

Then open a web browser with:
https://localhost:9009/squash/login

Otel agent is at:
http://localhost:9316

Prometheus runs at
http://localhost:9090/


## Squash Orchestrator


