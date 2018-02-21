# Step 2. Build & run the Liberty app locally talking to remote DB2 and LDAP servers

In this step, we are going to build and run the Liberty app locally and connect it to the remote DB2 and LDAP servers simulating what would be a real production scenario.

1. [Build the Liberty app](#build-the-liberty-app)
    * [Get the project repositories](#get-the-project-repositories)
    * [Build the ear file using Maven](#build-the-ear-file-using-maven)
2. [Create a Liberty server](#create-a-liberty-server)
3. [Configure the Liberty server](#configure-the-liberty-server)
4. [Deploy and run the app](#deploy-and-run-the-app)

### Build the Liberty app

#### Get the project repositories

In this step we need to clone two GitHub repositories. The first one includes the instructions for this very same tutorial and all the configuration files needed to complete it.

On [a terminal window](troubleshooting.md#open-the-terminal), execute

1. `cd ~/PurpleCompute/git`

2. `git clone https://github.com/ibm-cloud-architecture/refarch-jee.git`

   ![Local 1](/static/imgs/localEAR/local1.png)

The second one includes the application source code. On [a terminal window](troubleshooting.md#open-the-terminal), execute

1. If you completed **Step 1** in this tutorial, then execute `rm -rf ~/git/refarch-jee-customerorder/`. Otherwise, skip this step.
2. `git clone https://github.com/ibm-cloud-architecture/refarch-jee-customerorder.git`
3. `cd refarch-jee-customerorder`
4. `git checkout liberty`

   ![Local 2](/static/imgs/localEAR/local2.png)

#### Build the ear file using Maven

Maven is a project management tool. It is based on Project Object Model (POM). Maven is generally used for projects build, dependency and documentation. Basically, it simplifies the project build. We are using Maven for building our project ear. On [a terminal window](troubleshooting.md#open-the-terminal), execute:

1. `cd CustomerOrderServicesProject`
2. `mvn clean package`

This command will build **CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear** in **target** directory of **CustomerOrderServicesApp** for you. You can see the below message once the build is successful.

   ![Local 8](/static/imgs/localEAR/local8.png)

### Create a Liberty server

**If you did not complete** [**step 1**](step1.md) **on this tutorial**, you must create a Liberty server to run the Customer Order Services application on. In order to do so, execute the following instructions on [a terminal window](troubleshooting.md#open-the-terminal):

1. `cd ~/PurpleCompute/wlp/bin`
2. `./server create`

   ![Create server](/static/imgs/localEAR/local3.png)

You should now have a Liberty server called **defaultServer** created.

### Configure the Liberty server

Before running the application on the Liberty server, we need to configure it. As we said in this tutorial in [step 1](step1.md#configure-websphere-liberty-server), the Liberty server is configured by using config files rather than through an administration console as in previous WebSphere Application Server versions. These configuration files are called **server.xml** and **server.env** which reside in the liberty server directory.

For this tutorial, we provide you with these configuration files ready to be used out of the box so that the Customer Order Services application works right away in Liberty. You only need to copy them from the GitHub repository location, which you have just downloaded to your machine, to the Liberty server directory on your machine and install the server's utilities. For doing all that, execute on [a terminal window](troubleshooting.md#open-the-terminal):

1. Copy **server.xml** into the Liberty server directory:

   ```
   cp /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.xml \
   /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer
   ```

2. Copy **server.env** into the Liberty server directory:

   ```
   cp /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.env.step2 \
   /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer/server.env
   ```

   You should now see the following two files in your Liberty server path (`/home/skytap/PurpleCompute/wlp/usr/servers/defaultServer`)

   ![Step 2 img 1](/static/imgs/LibertyToolKit/step2-1.png)

3. The correct NodePort address will need to be specified in the copied *server.env* file, as this value changes for every Kubernetes deployment.  This value is acquired via the `kubectl get services` command:

   ![Configure 1](/static/imgs/toLiberty/Source85.png)

   **IMPORTANT:** you **must** have completed the [Recreate Db2 Datastore on ICP](step1.md#recreate-db2-datastore-on-icp) section in previous step 1 in order to see the database service above. If you have not, please complete it now.

4. Update the new server.env file by replacing the string **REPLACE_WITH_NODEPORT** with the value to the right of 50000. In the example above, this value would be **30494**. On [a terminal window](troubleshooting.md#open-the-terminal), execute:

   1. `gedit /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer/server.env`

   2. Change `REPLACE_WITH_NODEPORT` with the correct NodePort above explained.

   3. Save & close.

5. Install the Liberty server features/utilities needed to run the Customer Order Services application (specified in the server.xml file).

   On [a terminal window](troubleshooting.md#open-the-terminal), execute:

   ```
   ~/PurpleCompute/wlp/bin/installUtility install <server_name>
   ```
   where *<server_name>* is the name you have given to your Liberty server when you created it either in [step 1](#install-websphere-application-server-liberty-locally) or in [this step](#create-a-liberty-server). If you have followed the instructions as they are, the Liberty server name should be **defaultServer**.

   * If you completed step 1 on this tutorial, you see that no additional features have been installed:

   ![Configure server 1](/static/imgs/localEAR/local4.png)

   * Otherwise, you see several new features being installed:

   ![Configure server 2](/static/imgs/localEAR/local5.png)

For more information on the Liberty server configuration specified in the server.xml please read [Configure WebSphere Liberty Server](step1.md#configure-websphere-liberty-server) section in step 1.

### Deploy and run the app

Now, we want to deploy the ear file our Customer Order Services application got built into. In order to do so, we need to drop this ear file into an specific folder within the Liberty server installation directory. On [a terminal window](troubleshooting.md#open-the-terminal), execute:

1. `cd /home/skytap/PurpleCompute/git/refarch-jee-customerorder/CustomerOrderServicesApp/target` <sup>\*</sup>_(You should see the build output ear file called **CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear**)_
2. `cp CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer/apps`

Now, you are done with the configuration and the app is ready for deployment. To run the app on Liberty, execute on [a terminal window](troubleshooting.md#open-the-terminal):

1. Go into the Liberty server binaries folder: `cd /home/skytap/PurpleCompute/wlp/bin`
2. Start the server: `./server start defaultServer`

   ![Start server](/static/imgs/localEAR/local6.png)

3. Open your browser and point it to http://10.0.0.1:9081/CustomerOrderServicesWeb/#shopPage
4. Login as the user `rbarcia` with the password of `bl0wfish`

   ![App running](/static/imgs/LibertyToolKit/step2apprunning.png)

5. Finally, stop the server execute on [a terminal window](troubleshooting.md#open-the-terminal): `./server stop defaultServer`

   ![Stop server](/static/imgs/localEAR/local7.png)

# Next step

Click [here](step3.md) to go to the next step, step 3.

Click [here](tutorial.md) to go to the tutorial initial page.
