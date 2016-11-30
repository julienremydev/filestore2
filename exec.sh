#!/bin/bash

java -jar /opt/jboss/wildfly/fakeSMTP.jar -s -b -p 25 &
/opt/jboss/wildfly/bin/standalone.sh -c standalone-full.xml -b 0.0.0.0 
