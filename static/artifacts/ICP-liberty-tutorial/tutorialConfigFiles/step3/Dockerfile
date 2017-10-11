FROM websphere-liberty:webProfile7

COPY Common/server.xml /config
COPY Common/server.env.docker /config/server.env
COPY /home/vagrant/db2lib/db2jcc4.jar /db2lib/db2jcc4.jar
COPY /home/vagrant/db2lib/db2jcc_lisence_cu.jar /db2lib/db2jcc_lisence_cu.jar
COPY CustomerOrderServicesApp/target/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear /config/apps

RUN /opt/ibm/wlp/bin/installUtility install  --acceptLicense \
    appSecurity-2.0 \
    ejbLite-3.1 \
    ldapRegistry-3.0 \
    localConnector-1.0 \
    jaxrs-1.1 \
    jdbc-4.1 \
    jpa-2.0 \
    jsp-2.3 \
    servlet-3.1
