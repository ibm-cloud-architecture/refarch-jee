# Step 3. Containerize the Liberty app

In this step, we are going to use Docker technology to containerise our Liberty application so that it can be then deployed to a virtualized infrastructure using a containers orchestrator such as Kubernetes.

1. [Containerise the app](#containerise-the-app)
    * [Dockerfile](#dockerfile)
    * [Build the container image from Dockerfile](#build-container-image-from-dockerfile)
    * [Run the containerised app](#run-the-containerised-app)

### Containerise the app

#### Dockerfile

We are using Docker to containerize the app. Using Docker, we can pack, ship and easily run the apps on a portable lightweight container that can run anywhere virtually.

Lets have a look at our [Dockerfile](tutorialConfigFiles/Dockerfile) file

```
FROM websphere-liberty:webProfile7

COPY Common/server.xml /config
COPY Common/server.env.docker /config/server.env
COPY Common/db2jcc4.jar /db2lib/db2jcc4.jar
COPY Common/db2jcc_license_cu.jar /db2lib/db2jcc_license_cu.jar
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

```

1. **FROM** instruction is used to set the base image. We are setting the base image to **websphere-liberty:webProfile7**.
2. **COPY** instruction is used to copy directories and files from a source specified to a destination in the container file system.
   - We are copying the **server.xml** from **Common** directory to **config** folder in the container.
   - We are replacing the contents of **server.env** in **config** folder with contents of **server.env.docker** in **Common** directory.
   - We are copying the **DB2 libraries** needed by the server to connect our Java app to our DB2 database.
   - We are also copying the **ear** file from **CustomerOrderServicesApp** and placing it in **apps** folder residing in **config**.
3. **RUN** instruction helps us to execute the commands.
   - Here we have a pre-condition to install all the utilities in server.xml. We can use RUN command to install them on top of the base image.

Using this docker file, we build a docker image and using this image we will launch the docker container.

#### Build the container image from Dockerfile

Because the Dockerfile is set to use the files in the `Common` directory from the source code github repo, we must then replace those files with our tutorial specific configuration files before building the Docker image. That is, we need to copy **server.xml** and **server.env.docker** files into the `Common` folder. For doing it, execute on a terminal window:

1. `cp /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.xml /home/skytap/PurpleCompute/git/refarch-jee-customerorder/Common/`
2. `cp /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.env.step3 /home/skytap/PurpleCompute/git/refarch-jee-customerorder/Common/server.env.docker`

Likewise, we need to do the same with the **Dockerfile** we will use for this tutorial:

1. `cp /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/Dockerfile /home/skytap/PurpleCompute/git/refarch-jee-customerorder/`

Also, we have to copy the DB2 libraries WebSphere Application Server Liberty server needs to enable our application to connect to the DB2 database. We have to copy these DB2 libraries into the `Common` folder too since that is where we have defined these libraries to be in our Dockerfile. Again, execute on a terminal:

1. `cp /home/skytap/PurpleCompute/db2lib/db2jcc4.jar /home/skytap/PurpleCompute/git/refarch-jee-customerorder/Common/`
2. `cp /home/skytap/PurpleCompute/db2lib/db2jcc_license_cu.jar /home/skytap/PurpleCompute/git/refarch-jee-customerorder/Common/`

Finally, we are now ready to build the container:

1. `cd /home/skytap/PurpleCompute/git/refarch-jee-customerorder`
2. `docker build -t "customer-order-services:liberty" .`   (mind the dot at the end)

   ![Docker 1](/static/imgs/localDocker/docker1.png)

You can verify your docker image has been successfully built by using the command `docker images` on your terminal:

   ![Docker 2](/static/imgs/localDocker/docker2.png)

#### Run the containerised app

When starting the container, we feed in environment specific configuration to direct the application to the db2 and ldap servers for the lab environment. We used to set that configuration in the **server.xml** and **server.env** files for the Liberty server. Now, when you containerise an application your should extract that environment specific configuration out and provide it at runtime based on where your container is going to run. That way, your container and therefore your application are portable.

That environment specific configuration to get the containerised Customer Order Services application to work on our ICP environment for this tutorial and to connect out to an on-premise LDAP server is now stored in these two files: [remote_orderdb.env](tutorialConfigFiles/orderdb.env) and [ldap.env](tutorialConfigFiles/ldap.env).

These files are located in our machine at `/home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles`

However, the port ICP exposes for our DB2 deployment changes from one deployment to another. As a result, we can't set it beforehand for this tutorial and we need to specify the appropriate NodePort for our DB2 deployment in the `remote_orderdb.env` file manually (same way we have already done in this tutorial when we ran the application locally outside of any container where we had to set appropriate NodePort straight into the `server.env`).

The DB2 NodePort value that ICP exposes can be acquired via the `kubectl get services` command:

   ![Orderdb](/static/imgs/toLiberty/Source85.png)

Update the `remote_orderdb.env` file by replacing the string **REPLACE_WITH_NODEPORT** with the NodePort value from above (30494 in our example):

   1. On a terminal window: `gedit /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/remote_orderdb.env`

   2. Change `REPLACE_WITH_NODEPORT` with the correct NodePort above explained.

   3. Save & close.


**IMPORTANT:** The above files are configured to work with this tutorial default values. If you decided to use any different value than the default ones throughout this tutorial, please update the aforementioned files accordingly.

Finally, to run the docker image, execute the following on a terminal window:

```
docker run --name customer-order-services \
  --env-file /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/ldap.env \
  --env-file /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/remote_orderdb.env \
  -p 9081:9080 customer-order-services:liberty
```

When the Docker container is running, you can see the below output.

   ![Docker 3](/static/imgs/localDocker/docker3.png)

Now your application is running locally. To check it out, open your browser and point it out to

http://10.0.0.1:9081/CustomerOrderServicesWeb/#shopPage

As usual, login as the user `rbarcia` with the password of `bl0wfish`.

   ![App running](/static/imgs/LibertyToolKit/AppRunningLocally.png)

After doing all the desired verifications, stop the running container by pressing `ctrl+c` on your terminal window where you ran the Docker container from.

   ![Docker 4](/static/imgs/localDocker/docker4.png)

# Next step

Click [here](step4.md) to go to the next step, step 4.

Click [here](tutorial.md) to go to the tutorial initial page.
