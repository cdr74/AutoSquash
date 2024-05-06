# AutoSquash

Automate the process to download Squash TM and Orchestrator from official distribution, patch for secure and scalable operation. Create a package (tar ball or docket tbd) for distribution to infrastructure.

The goal is that a distribution package is created in a reproducible fashion without any manual interaction.

**High level approach**

-   Use the prod tar.gz from the official distribution
-   Create a copy with all files that need changes in templates folder
-   Automate the patching and re-packaging process (coule be run in a pipeline)
-   Create another script (pipeline) to distribute the re-configured set-up

_Caution_: there are multiple sources of old verions on bitbucket, github etc!

## Monitoring

Here are all the involved ports / agents / processes:

-   Tomcat JMX is enabled as part of the startup.sh
    Exposes data on port 9099
    Use this to check jmx: jconsole service:jmx:rmi:///jndi/rmi://localhost:9099/jmxrmi
-   Prometheus JMX exporter runs as seperate process and is started in startup.sh
    - Grabs data from JMX port 9099
    - Exposes data on port 9033 
    - Config in jmx_exporter_config.yml
      https://github.com/prometheus/jmx_exporter/tree/release-0.20.0
-   OTEL agent (1 per JVM) runs as part of the tomcat process to collect Java metrics using byte code instrumentation
    -   the agent sends data over http to the OTEL collector listening on 4318 (stratup.sh)
        https://opentelemetry.io/docs/languages/java/automatic/configuration/
-   OTEL collector (1 per cluster) to aggregate data from collectors and exports to prometheus (format change)
    -   the collector sends data to prometheus listening on 9316 (otel-agent-collector.yml)
        https://opentelemetry.io/docs/collector/configuration/
-   Prometheus can be accessed from port 9090
-   Grafana to visualize data runs on port 3000 and connects to prometheus over docker network (http://prometheus:9090)

## Squash TM

Squash TM is a Spring Boot based app with integrated Tomcat v9.

**Completed**

-   Set proper GC param in "startup.sh" (currently at 2GB, should be 8GB in prod)
-   Disable http and enforce https in "application.properties", requires patching of war file
-   Enable JMX for monitoring in "startup.sh" and add JMX scraper from Prometheus
-   Enable OTEL javaagent in "startup.sh"; needs download of the agent
-   Connect with OTEL collector and the send dat to prometheus (should be seperate package for distribution)
-   Enabled Xsquash4GitLab connector (plugin)
-   Enabled gitlab.bugtracker bugtracker (plugin)
-   Added Grafana to Prometheus

**Todo**

-   Add root CA to keystore and tune ssl for performance (out of the box is ... meh)
-   Set a proper Tomcat connector config "application.properties", requires patching of war file
-   Prod grade log config in "log4j2.xml"
-   find a smarter patching approach
    -   e.g. Set variable in the build script with the new parameters
    -   e.g. Copy old file as .orig and replace them with the new one
-   (?) Packaging as Docker or tar ball
-   (?) Do we load some pre-default config ? e.g. gitlab server, plugin setup, template, etc.

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

Steps to get OTEL collector and prometheus going see `start_monitoring.sh`

Testing the app locally, go to bin directury by running `./startup.sh &`

Then open a web browser with https://localhost:9009/squash/login

Prometheus runs at http://localhost:9090/

## Squash Orchestrator
