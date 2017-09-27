# Tutorial - WebSphere on IBM Cloud Private

This tutorial aims to drive readers throughout the process of migrating an existing WebSphere Application Server 7 application to run on the new WebSphere Application Server Liberty profile to then containerise it and deploy it to the on premises IBM Cloud Private, orchestrated by Kubernetes.

For doing so, we are going to go through the following steps below. Each step will have its instructions on a separate readme file for clarity and simplicity.

### Pre-requisites

In order to carry out this tutorial, you will need a development environment with the following tools installed on it:

* [Java SDK 1.8](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)
* [Eclipse Neon 3](http://www.eclipse.org/downloads/packages/eclipse-ide-java-ee-developers/neon3)
* [WebSphere Development Tools for eclipse](https://marketplace.eclipse.org/content/ibm-websphere-application-server-v9x-developer-tools)
* [WebSphere Application Migration Toolkit](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Application_Server_Migration_Toolkit)
* [WebSphere Application Server Liberty profile](https://developer.ibm.com/wasdev/downloads/download-latest-stable-websphere-liberty-runtime/)
* [GitHub](https://help.github.com/articles/set-up-git/)
* [Maven](https://maven.apache.org/download.cgi)
* [Docker](https://docs.docker.com/engine/installation/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

In our case, a skytap development environment will be provided with the tools aforementioned already installed on it.

### SkyTap images ###

1. Use the PurpleCompute series of SkyTap images for this tutorial.
2. Login to your skytap machine on the Desktop vm image.
3. Use the password: A1rb0rn3

### Step 1. Modernise application to run on WebSphere Liberty profile (Optional)
--------------------------------------------------------------------------------

In this step, we are going to make the modifications needed both at the application level and the server configuration level to migrate our legacy WebSphere Application Server 7 application to run on the WebSphere Application Server Liberty profile.

Click [here](step1.md) for the instructions.

### Step 2. Build & run the Liberty app locally talking to remote DB2 and LDAP servers
--------------------------------------------------------------------------------------

In this step, we are going to build and run the Liberty app locally and connect it to the remote DB2 and LDAP servers simulating what would be a real production scenario.

Click [here](step2.md) for the instructions.

### Step 3. Containerize the Liberty app
----------------------------------------

In this step, we are going to use Docker technology to containerize our Liberty application so that it can be then deployed to a virtualized infrastructure using a containers orchestrator such as Kubernetes.

Click [here](step3.md) for the instructions.

### Step 4. Write Kubernetes YAMLs, including Deployment and Services stanzas
-----------------------------------------------------------------------------

In this step, we are going to write the needed configuration files, deployment files, etc for a container orchestrator such as Kubernetes to get our Liberty app appropriately deployed onto our virtulized infrastructure.

Click [here](step4.md) for the instructions.

### Step 5. Deploy the Liberty app on your IBM Cloud Private
------------------------------------------------------------

In this final step, we are going to deploy our Liberty app to our IBM Cloud Private through the Kubernetes command line interface.

Click [here](step5.md) for the instructions.

## Extra - Advanced topics

The following are extra work we have done for the CustomerOrderServices application which are not part of this tutorial goals but are essential topics these days, resulting on a good learning piece for any reader.

### Evolve your monolithic application into microservices
---------------------------------------------------------

Now that you've got a traditional Liberty application up and running on the platform, it's time to evolve it!

Check [this](extra.md) out!

### DevOps - Build and deploy using Jenkins 
--------------------------------------------

There is always time to be lazy. All steps above to compile, build and deploy the application can be automated.
Read [these](DevOps/DevOps.md) instructions to setup Jenkins on IBM Cloud Private to do the job for you.

