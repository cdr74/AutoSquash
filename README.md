# AutoSquash

Automate the process to download Squash TM and Orchestrator from official distribution and patch for secure and scalable operation. Create a package (tar ball or docket tbd) for distribution locally.

The goal is that a secured distribution package is created in a reproducible fashion without any manual interaction.

**High level approach**

-   Use the prod tar.gz from the official distribution
-   Create a copy with all config files that need changes in templates folder
-   Unpack org distribution and apply config from template folder
-   Create another script (pipeline) to distribute the re-configured set-up

_Caution_: there are multiple sources of old verions on bitbucket, github etc!

## Monitoring

Squash TM is a Spring Boot app and comes with actuator; which makes it well prepared for Prmetheus / Grafana stack... unfortunatly micrometer is not added (but in the backlog from Squash team):

-   Enable actuator with the `squash.tm.cfg.properties` file in templates `configure_squash.sh`adds the content dynamically 
-   Prometheus (docker runtime) collects the data and runs on 9090
-   Grafana (docker runtime) visualizes data and runs on 3000; add prometheus as data source (http://localhost:9090)

See `start_monitoring.sh` and `stop_monitoring.sh` for info on Prometheus and Grafana.

## Squash TM

Squash TM is a Spring Boot based app with integrated Tomcat v9 and actuator for prod observability.

**Completed**

-   Set Java GC to 8GB (2GB for test) and enable G1 in `startup.sh`
-   Disable http and enforce https in `squash.tm.cfg.properties` (could also be done in application.properties - patch war file)
-   Enabled Xsquash4GitLab connector (plugin)
-   Enabled gitlab.bugtracker bugtracker (plugin)
-   Added Grafana and Prometheus

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
