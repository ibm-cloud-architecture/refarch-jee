# Step 3. Containerize the Liberty app

In this step, we are going to use Docker technology to containerise our Liberty application so that it can be then deployed to a virtualised infrastructure using a containers orchestrator such as Kubernetes.

1. [Containerise the app](#containerise-the-app)
    * [Dockerfile](#dockerfile)
    * [Build the container image from Dockerfile](#build-the-container-image-from-dockerfile)
    * [Run the containerised app](#run-the-containerised-app)

### Containerise the app

#### Dockerfile

We are using Docker to containerise the app. Using Docker, we can pack, ship and easily run the apps on a portable lightweight container that can run anywhere virtually.

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

Because the Dockerfile is set to use the files in the **Common** directory from the source code github repository, we must then replace those files with our tutorial specific configuration files before building the Docker image. That is, we need to copy **server.xml** and **server.env.docker** files into the **Common** folder. For doing so, execute on [a terminal window](troubleshooting.md#open-the-terminal):

1. `cd ~`
2. `cp ~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.xml ~/PurpleCompute/git/refarch-jee-customerorder/Common/`
3. `cp ~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.env.step3 ~/PurpleCompute/git/refarch-jee-customerorder/Common/server.env.docker`

Likewise, we need to do the same with the **Dockerfile** we will use for this tutorial:

1. `cp ~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/Dockerfile ~/PurpleCompute/git/refarch-jee-customerorder/`

Also, we have to copy the DB2 libraries WebSphere Application Server Liberty server needs to enable our application to connect to the DB2 database. We have to copy these DB2 libraries into the **Common** folder too since that is where we have defined these libraries to be in our Dockerfile. Again, execute on [a terminal window](troubleshooting.md#open-the-terminal):

1. `cp ~/PurpleCompute/db2lib/db2jcc4.jar ~/PurpleCompute/git/refarch-jee-customerorder/Common/`
2. `cp ~/PurpleCompute/db2lib/db2jcc_license_cu.jar ~/PurpleCompute/git/refarch-jee-customerorder/Common/`

Finally, we are now ready to build the container:

1. `cd ~/PurpleCompute/git/refarch-jee-customerorder`
2. `docker build -t "customer-order-services:liberty" .`   (mind the dot at the end)

   ![Docker 1](/static/imgs/localDocker/docker1.png)

You can verify your docker image has been successfully built by running the command `docker images | grep liberty` on your [terminal window](troubleshooting.md#open-the-terminal):

   ![Docker 2](/static/imgs/localDocker/docker2.png)

#### Run the containerised app

As already said in this tutorial, our Customer Order Services application uses a **DB2** database for storing its data and an **LDAP** server to implement RBAC security. We used to specify the connectivity details for both db2 database and ldap server in the **server.xml** and **server.env** files, which the Liberty server would read at startup, when our application ran locally. Now, when you containerise an application, since it should be done in a manner that it can be portable across different environments, you should then extract that environment specific configuration out and provide it at runtime based on where your container is going to run. In the previous section, we packaged the code, libraries, the Liberty server, and its configuration files server.xml and server.env. However, these Liberty server configuration files are now **parametrised** so that they can get the appropriate configuration from the environment the container is going to run on. As a result, **we now have our application containerised and portable** ready to run on different environments with no change at all but the configuration for the DB2 database and LDAP server it is injected at runtime.

That environment specific configuration to get the containerised Customer Order Services application to work on our ICP environment for this tutorial is now stored in these two files: [remote_orderdb.env](tutorialConfigFiles/orderdb.env) and [ldap.env](tutorialConfigFiles/ldap.env) which are located in our machine at `~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles`. These files will be "injected" when the container runs.

However, the port ICP exposes for our DB2 deployment changes from one deployment to another. As a result, we can't set it beforehand for this tutorial and we need to manually specify the appropriate NodePort for our DB2 deployment in the **remote_orderdb.env** file (same way we have already done in this tutorial when we the application ran locally outside of any container where we had to set appropriate NodePort straight into the **server.env**) before it gets "injected" at runtime.

The DB2 NodePort value that ICP exposes can be acquired via executing the `kubectl get services` command on [a terminal window](troubleshooting.md#open-the-terminal):

   ![Orderdb](/static/imgs/toLiberty/Source85.png)

Update the **remote_orderdb.env** file by replacing the string **REPLACE_WITH_NODEPORT** with the NodePort value from above (30494 in our example). On [a terminal window](troubleshooting.md#open-the-terminal), execute:

   1. `gedit ~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/remote_orderdb.env`

   2. Change `REPLACE_WITH_NODEPORT` with the correct NodePort above explained.

   3. Save & close.

**IMPORTANT:** The above files are configured to work with this tutorial default values. If you decided to use any different value than the default ones throughout this tutorial, please update the aforementioned files accordingly.

Finally, to run the docker image, execute the following on [a terminal window](troubleshooting.md#open-the-terminal):

```
docker run --name customer-order-services \
  --env-file ~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/ldap.env \
  --env-file ~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/remote_orderdb.env \
  -p 9081:9080 customer-order-services:liberty
```

When the Docker container is running, you can see the below output.

   ![Docker 3](/static/imgs/localDocker/docker3.png)

Now your application is running locally. To check it out, open your browser and point it out to

http://10.0.0.1:9081/CustomerOrderServicesWeb/#shopPage

As usual, login as the user `rbarcia` with the password of `bl0wfish`.

   ![App running](/static/imgs/LibertyToolKit/AppRunningLocally.png)

After doing all the desired verifications, stop the running container by pressing `ctrl+c` on the same terminal window you ran the Docker container from.

   ![Docker 4](/static/imgs/localDocker/docker4.png)

# Next step

Click [here](step4.md) to go to the next step, step 4.

Click [here](tutorial.md) to go to the tutorial initial page.
