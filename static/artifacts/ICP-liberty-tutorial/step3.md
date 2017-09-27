# Step 3. Containerize the Liberty app

In this step, we are going to use Docker technology to containerise our Liberty application so that it can be then deployed to a virtualized infrastructure using a containers orchestrator such as Kubernetes.

1. [Containerise the app](#containerise-the-app)
    * [Dockerfile](#dockerfile)
    * [Build the container image from Dockerfile](#build-container-image-from-dockerfile)
    * [Run the containerised app](#run-the-containerised-app)

### Containerise the app

#### Dockerfile

We are using Docker to containerize the app. Using Docker, we can pack, ship and easily run the apps on a portable lightweight container that can run anywhere virtually.

Lets have a look at our [Docker file](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/blob/liberty/Dockerfile)

```
FROM websphere-liberty:webProfile7

COPY Common/server.xml /config
COPY Common/server.env.docker /config/server.env
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

ADD https://artifacts.alfresco.com/nexus/content/repositories/public/com/ibm/db2/jcc/db2jcc4/10.1/db2jcc4-10.1.jar /db2lib/db2jcc4.jar

ADD http://download.osgeo.org/webdav/geotools/com/ibm/db2jcc_license_cu/9/db2jcc_license_cu-9.jar /db2lib/db2jcc_lisence_cu.jar

```

1. **FROM** instruction is used to set the base image. We are setting the base image to **websphere-liberty:webProfile7**.
2. **COPY** instruction is used to copy directories and files from a source specified to a destination in the container file system.
   - We are copying the **server.xml** from **Common** directory to **config** folder in the container.
   - We are replacing the contents of **server.env** in **config** folder with contents of **server.env.docker** in **Common** directory.
   - We are also copying the **ear** file from **CustomerOrderServicesApp** and placing it in **apps** folder residing in **config**.
3. **RUN** instruction helps us to execute the commands. 
   - Here we have a pre-condition to install all the utilities in server.xml. We can use RUN command to install them on top of the base image.
4. **ADD** instruction is used to copy something using the remote URL. This is very similar to COPY command but with additional features like remote URL support and tar extraction.
   - In this case, we are downloading the jar files required for the app.

Using this docker file, we build a docker image and using this image we will launch the docker container.

#### Build the container image from Dockerfile

Because the Dockerfile is set to use the files in the `Common` directory from the source code github repo, we must then replace those files with our tutorial specific configuration files before building the Docker image. That is, we need to copy server.xml and server.env.docker files into the `Common` folder.

1. `cp /home/skytap/PurpleCompute/git/refarch-jee-customerorder/tutorial/tutorialConfigFiles/step3/server.xml /home/skytap/PurpleCompute/git/refarch-jee-customerorder/Common/`
2. `cp /home/skytap/PurpleCompute/git/refarch-jee-customerorder/tutorial/tutorialConfigFiles/step3/server.env.docker /home/skytap/PurpleCompute/git/refarch-jee-customerorder/Common/`

Finally, we are now ready to build the container:

1. `cd /home/skytap/PurpleCompute/git/refarch-jee-customerorder`
2. `docker build -t "customer-order-services:liberty" .` (mind the dot at the end)

You can verify your docker image using the command `docker images`. You will find the image.

```
REPOSITORY                                          TAG                 IMAGE ID            CREATED             SIZE
customer-order-services                             liberty             8c3e4d876dad        2 hours ago         424MB
websphere-liberty                                   webProfile7         5fd996d31e9f        11 hours ago        392MB
```

#### Run the containerised app
When starting the container, we feed in environment specific variables to direct the application to the db2 and ldap servers for the lab environment.
There are three specific files configured: `orderdb.env`, `inventordydb.env` and `ldap.env`.
These files are located in `/home/skytap/PurpleCompute/git/refarch-jee-customerorder/tutorial/tutorialConfigFiles`


Run the docker image: 

```
docker run \
  --env-file tutorial/tutorialConfigFiles/ldap.env \
  --env-file tutorial/tutorialConfigFiles/orderdb.env \
  --env-file tutorial/tutorialConfigFiles/inventorydb.env \
  -p 9080:9080 customer-order-services:liberty
```

When it is complete, you can see the below output.

```
[AUDIT   ] CWWKT0016I: Web application available (default_host): http://4963b17bece0:9080/CustomerOrderServicesWeb/
[AUDIT   ] CWWKT0016I: Web application available (default_host): http://4963b17bece0:9080/CustomerOrderServicesTest/
[AUDIT   ] CWWKZ0001I: Application CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear started in 2.366 seconds.
[AUDIT   ] CWWKF0012I: The server installed the following features: [jsp-2.3, ejbLite-3.1, servlet-3.1, ssl-1.0, jndi-1.0, localConnector-1.0, federatedRegistry-1.0, appSecurity-2.0, jdbc-4.1, jaxrs-1.1, el-3.0, ldapRegistry-3.0, json-1.0, distributedMap-1.0, beanValidation-1.0, jpa-2.0].
[AUDIT   ] CWWKF0011I: The server defaultServer is ready to run a smarter planet.
```
Now your application is running locally. To check it out, open your browser and point it out to

http://localhost:9080/CustomerOrderServicesWeb/#shopPage
 
 
As usual, login as the user `rbarcia` with the password of `bl0wfish`.

<p align="center">
<img src="https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/AppRunningLocally.png">
</p>

After doing all the desired verifications, stop the running container by pressing `ctrl+c`
