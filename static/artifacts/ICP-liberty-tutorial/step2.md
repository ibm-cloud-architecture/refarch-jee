# Step 2. Build & run the Liberty app locally talking to remote DB2 and LDAP servers

In this step, we are going to build and run the Liberty app locally and connect it to the remote DB2 and LDAP servers simulating what would be a real production scenario.

1. [Build the Liberty app](#build-the-liberty-app)
    * [Get the project repositories](#get-the-project-repositories)
    * [Build the ear file using Maven](#build-the-ear-file-using-maven)
2. [Configure the Liberty server](#configure-the-liberty-server)
3. [Deploy and run the app](#deploy-and-run-the-app)

### Build the Liberty app

#### Get the project repositories

In this step we need to clone two GitHub repositories. The first one includes the instructions for this very same tutorial and all needed files to complete it.

1. Open a new terminal
2. `cd ~/PurpleCompute/git`
3. `git clone https://github.com/ibm-cloud-architecture/refarch-jee.git`

The second one includes the application source code. You can clone this repository from its main GitHub repository page and checkout the appropriate branch for this version of the application. If you completed **Step 1** in this tutorial, then execute `rm -rf ~/git/refarch-jee-customerorder/`.

1. `git clone https://github.com/ibm-cloud-architecture/refarch-jee-customerorder.git`
2. `cd refarch-jee-customerorder`
3. `git checkout icp-bootcamp-v1` (disregard warning output)

#### Build the ear file using Maven

Maven is a good project management tool. It is based on Project Object Model (POM). Maven is generally used for projects build, dependency and documentation. Basically, it simplifies the project build. We are using Maven for building our project ear.

1. `cd CustomerOrderServicesProject`
2. `mvn clean package`

This command will build **CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear** in **target** directory of **CustomerOrderServicesApp** for you. You can see the below message once the build is successful.

```
[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary:
[INFO]
[INFO] project ............................................ SUCCESS [  0.157 s]
[INFO] CustomerOrderServices .............................. SUCCESS [  1.514 s]
[INFO] Customer Order Services Web Module ................. SUCCESS [  9.391 s]
[INFO] Customer Order Services Test Module ................ SUCCESS [  0.598 s]
[INFO] CustomerOrderServicesApp ........................... SUCCESS [  1.294 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 13.061 s
[INFO] Finished at: 2017-08-30T11:08:51-05:00
[INFO] Final Memory: 30M/324M
[INFO] ------------------------------------------------------------------------
```

### Configure the Liberty server

Before running the application on the Liberty server, we need to configure it. As we said in this tutorial in step 1, the Liberty server is configured by using config files rather than through an administration console as in previous WebSphere Application Server versions. These configuration files are called **server.xml** and **server.env** which reside in the liberty server directory.

For this tutorial, we provide you with these configuration files ready to be used out of the box so that the Customer Order Services application works right away in Liberty. You only need to copy them from the GitHub repository location, which you have just downloaded to your machine, to the Liberty server directory on your machine:

1. Copy server.xml into the Liberty server directory
```
cp /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.xml \
   /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer
```
2. Copy server.env into the Liberty server directory
```
cp /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/server.env.step2 \
   /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer/server.env
```

![Step 2 img 1](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/step2-1.png)

3. The correct NodePort address will need to be specified in the copied *server.env* file, as this value changes for every Kubernetes deployment.  This value is acquired via the `kubectl get services` command:
```
skytap@icpboot:~/PurpleCompute$ kubectl get services
NAME                      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                           AGE
db2-cos-ibm-db2oltp-dev   NodePort    10.1.0.231   <none>        50000:30943/TCP,55000:31124/TCP   32m
kubernetes                ClusterIP   10.1.0.1     <none>        443/TCP                           14d
```
4. Update the new server.env file by replacing the string **REPLACE_WITH_NODEPORT** with the value to the right of 50000.  In the example above, this value would be **30943**.
```
vi /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer/server.env
```

For more information on the configuration specified in the server.xml please read [Configure WebSphere Liberty Server](step1.md#configure-websphere-liberty-server) section in step 1.

### Deploy and run the app

Now, we want to deploy the ear file our Customer Order Services application got build into. In order to do so, we need to drop this ear file into an specific folder within the Liberty server installation directory.

1. `cd /home/skytap/PurpleCompute/git/refarch-jee-customerorder/CustomerOrderServicesApp/target` <sup>\*</sup>_(You should see the build output ear file called **CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear**)_
2. `cp CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear /home/skytap/PurpleCompute/wlp/usr/servers/defaultServer/apps`


Now, you are done with the configuration and the app is ready for deployment. To run the app on Liberty,

1. Go into the Liberty server binaries folder: `cd /home/skytap/PurpleCompute/wlp/bin`
2. Before starting the server, to make sure all the utilities are installed, run the following command: `./installUtility install defaultServer` <sup>\*</sup>_(If it prompts you to accept the license by pressing 1, please accept it)_
3. Start the server: `./server start defaultServer`
4. Open your browser and point it to http://10.0.0.1:9081/CustomerOrderServicesWeb/#shopPage
5. Login as the user `rbarcia` with the password of `bl0wfish`

<p align="center">
<img src="https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/step2apprunning.png">
</p>

6. Finally, stop the server: `./server stop defaultServer`
