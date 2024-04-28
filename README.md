# AutoSquash

Automate the process to download Squash TM and Orchestrator from official distribution, patch for secure and scalable operation. Create a package (tar ball or docket tbd) for distribution to infrastructure. 

The goal is that a distribution package is created in a reproducible fashion without any manual interaction. 

**High level approach**
- Use the prod tar.gz from the official distribution
- Create a copy with all files that need changes in templates folder
- Automate the patching and re-packaging process (coule be run in a pipeline)

_Caution_: there are multiple sources of old verions on bitbucket, github etc!


## Monitoring

Basic story for Squash TM goes like this and should be similar for the Orchestrator:
- OTEL agent (1 per JVM) to collect Java metrics using byte code instrumentation 
- OTEL colelctor (1 per cluster) to aggregate data from collectors and export to prometheus (format change)
- JMX collector to get insight into Tomcat, data directly pulled from Prometheus, not involving the collector
- Grafana to visualize data in Prometheus


## Squash TM

Squash TM is a Spring Boot based app with integrated Tomcat v9. 

**Current status**
- (done) Set proper GC param in "startup.sh"
- (done) Enable JMX for monitoring  in "startup.sh" -> might replace this with prmetheus jmx exporter
- (done) Disable http and enforce https in "application.properties", requires patching of war file
- (todo) Add root CA to keystore and tune ssl for performance (out of the box is ... meh)
- (done) Enable OTEL javaagent in "startup.sh"; needs download of the agent
- (done) Connect with OTEL collector and the send dat to prometheus (should be seperate package for distribution)
- (todo) Setup Grafana to visualize data in prometheus
- (todo) Set a proper connector config for tomcat in "application.properties", requires patching of war file
- (todo) Prod grade log config in "log4j2.xml"
- (todo) Packaging as Docker or tar ball

All changes in config files in template folder are commented with "# CR:", could be a multi line change.
- (todo) find a smarter patching approach

We start with a pre-built tar.gz package: https://nexus.squashtest.org/nexus/#browse/browse:public-releases\
... alternative is start from source in: https://gitlab.com/henixdevelopment/open-source/squash\
... current maintenance branch is "maintenance-6.x", in case we want to compile by ourselfes\
... main Squash repository https://gitlab.com/henixdevelopment/open-source/squash/squashtest-tm-staging.git\

SquashTM installation instructions are found here: 
https://henixdevelopment.gitlab.io/squash/doc/squashtm-doc-en/v3/install-guide/install-squash/install-squash.html

Configuring the server for certificate use (to support ssl), eg adding keystore is not covered in the script. 
Checkout: https://tomcat.apache.org/tomcat-9.0-doc/ssl-howto.html 

Manual steps to perform once for local tests are to setup a keystore
```
 $JAVA_HOME/bin/keytool -genkey -alias tomcat -keyalg RSA
```

Manual steps to get OTEL collector and prometheus going
```
 docker pull otel/opentelemetry-collector
 docker  run -p 4318:4318 -v /home/chris/dev/AutoSquash/templates/SquashTM/conf/collector-config.yaml otel/opentelemetry-collector:latest &
 docker pull prom/prometheus
 docker run -p 9090:9090 -v /home/chris/dev/AutoSquash/templates/SquashTM/conf/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus &
```

Testing the app locally, go to bin directury by running `./startup.sh &`

Then open a web browser with https://localhost:9009/squash/login

Prometheus runs at http://localhost:9090/


## Squash Orchestrator


