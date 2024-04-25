# AutoSquash

Automate the process to download Squash TM and Orchestrator from official distribution, patch for secure and scalable operation, repackage for operations.

The idea is to keep pprod grade config files and an automation scipt in this repo; but not to replicate any assets from Squash side. 

_Caution_: there are multiple sources of old verions on bitbucket, github etc!


## Squash TM

Squash TM is a Spring Boot based app with integrated Tomcat v9. Our goal to run at prod scale is
- Set proper GC param in tomcat start script
- Disable http and enforce https
- Enable JMX for monitoring in startup script (do we also add a otel agent for tomcat?)
- Set a proper connector for large scale in server.xml
- Do we need to enforce log rotation?
- Do we want to put this in Docker right away (we should, but that needs we also want to add liveness probes)?

We start with a pre-built package: https://nexus.squashtest.org/nexus/#browse/browse:public-releases
... alternative is start from source in: https://gitlab.com/henixdevelopment/open-source/squash
... current maintenance branch is "maintenance-6.x"

Installation instructions are found here: 
https://henixdevelopment.gitlab.io/squash/doc/squashtm-doc-en/v3/install-guide/install-squash/install-squash.html

Main repository
https://gitlab.com/henixdevelopment/open-source/squash/squashtest-tm-staging.git



## Squash Orchestrator


