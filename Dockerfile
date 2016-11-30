# Use latest jboss/base-jdk:8 image as the base
FROM jboss/base-jdk:8

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 10.1.0.Final
ENV WILDFLY_SHA1 9ee3c0255e2e6007d502223916cefad2a1a5e333
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

# Expose the ports we're interested in
EXPOSE 8080:8080
EXPOSE 25:25
ADD fakeSMTP.jar /opt/jboss/wildfly/.


RUN mv /opt/jboss/wildfly/standalone/configuration/standalone-full.xml /tmp/.
ADD standalone-full.xml /opt/jboss/wildfly/standalone/configuration/standalone-full.xml 
RUN ls -la /opt/jboss/wildfly/standalone/configuration/
ADD filestore-ear.ear /opt/jboss/wildfly/standalone/deployments/filestore-ear.ear
RUN ls -la /opt/jboss/wildfly/standalone/deployments/

ADD exec.sh /opt/jboss/wildfly/

# Set the default command to run on boot
# This will boot WildFly in the standalone mode and bind to all interface
ENTRYPOINT ["/opt/jboss/wildfly/exec.sh"]
#CMD ["/opt/jboss/wildfly/bin/standalone.sh","-c","standalone-full.xml","-b","0.0.0.0"]
