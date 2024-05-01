# AutoSquash

Automate the process to download Squash TM and Orchestrator from official distribution, patch for secure and scalable operation. Create a package (tar ball or docket tbd) for distribution to infrastructure.

The goal is that a distribution package is created in a reproducible fashion without any manual interaction.

**High level approach**

-   Use the prod tar.gz from the official distribution
-   Create a copy with all files that need changes in templates folder
-   Automate the patching and re-packaging process (coule be run in a pipeline)

_Caution_: there are multiple sources of old verions on bitbucket, github etc!

## Monitoring

Basic story for Squash TM goes like this and should be similar for the Orchestrator:

-   OTEL agent (1 per JVM) to collect Java metrics using byte code instrumentation
    - the agent sends data over http to the collector listening on 4318 (stratup.sh)
    https://opentelemetry.io/docs/languages/java/automatic/configuration/
-   OTEL collector (1 per cluster) to aggregate data from collectors and export to prometheus (format change)
    - the collector sends data to prometheus listening on 9316 (otel-agent-collector.yml)
    https://opentelemetry.io/docs/collector/configuration/
-   Run prometheus JMX exporter to grab JMX over localhost from tomcat and send it to prometheus
    - the jmx exporter reads locally from 9099 (jmx_exporter_config.yml) and can be read from 9033 (startup.sh) 
    https://github.com/prometheus/jmx_exporter/tree/release-0.20.0 
-   Prometheus 
-   Grafana to visualize data in Prometheus

## Squash TM

Squash TM is a Spring Boot based app with integrated Tomcat v9.

**Completed**

-   Set proper GC param in "startup.sh" (currently at 2GB, should be 8GB in prod)
-   Disable http and enforce https in "application.properties", requires patching of war file
-   Enable JMX for monitoring in "startup.sh" and add JMX scraper from Prometheus
-   Enable OTEL javaagent in "startup.sh"; needs download of the agent
-   Connect with OTEL collector and the send dat to prometheus (should be seperate package for distribution)

**Todo**

-   Add root CA to keystore and tune ssl for performance (out of the box is ... meh)
    -   TO BE FIXED ! Current path is encoded in war /home/chris/.keystore
-   Setup Grafana to visualize data in prometheus
-   Set a proper Tomcat connector config "application.properties", requires patching of war file
-   Prod grade log config in "log4j2.xml"
-   find a smarter patching approach
    -   e.g. Set variable in the build script with the new parameters
    -   e.g. Copy old file as .orig and replace them with the new one
-   (?) Packaging as Docker or tar ball

All changes in config files in template folder are commented with "# CR:", could be a multi line change.

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
