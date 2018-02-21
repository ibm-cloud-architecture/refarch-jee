# Step 1. Modernise application to run on WebSphere Liberty profile (Optional)

In this step, we are going to make the modifications needed both at the application level and the server configuration level to migrate our WebSphere Application Server 7 application to run in WebSphere Liberty.

1.  [Analyze the application by using Transformation Advisor](#analyze-the-application-by-using-transformation-advisor)
2.  [Install WebSphere Application Server Liberty locally](#install-websphere-application-server-liberty-locally)
3.  [Get the code](#get-the-code)
4.  [Set up your development environment](#set-up-your-development-environment)
    - [Recreate Db2 Datastore on ICP](#recreate-db2-datastore-on-icp)
5.  [Source Code Migration](#source-code-migration)
    - [Software Analyzer Configuration](#software-analyzer-configuration)
    - [Run the Software Analyzer](#run-the-software-analyzer)
6.  [Configure WebSphere Liberty Server](#configure-websphere-liberty-server)
7.  [Run the application](#run-the-application)


## Analyze the application by using Transformation Advisor

Transformation Advisor enables a quick analysis of your on-premise applications for rapid deployment on WebSphere Application Server and Liberty running on a Public, Private, or Hybrid Cloud environment. Using the information available in your existing environments, Transformation Advisor runs a custom data collector on your on-premise application servers, identifying Java EE programming models on the application server, and then creates a high-level inventory of the content and structure of your applications. This analysis includes potential problems that could be encountered while moving the applications to the cloud or current levels of Java.

Transformation Advisor makes extensive use of the freely-available [IBM Websphere Application Server Migration Toolkit for Application Binaries (WAMT)](https://developer.ibm.com/wasdev/downloads/#asset/tools-Migration_Toolkit_for_Application_Binaries) and the [WebSphere Configuration Migration Toolkit (WCMT)](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Configuration_Migration_Tool). These tools are pre-integrated with the Data Collector and run as an all-in-one package on the target WAS servers. The applications are scanned and results from the Data Collector are sent back up to the Transformation Advisor as input to the recommendations engine.  Transformation Advisor calculates a development cost to perform the move and makes recommendations on the best target environment.

For more information on Transformation Advisor, you can reference the [Transformation Advisor homepage](https://developer.ibm.com/product-insights/transformation-advisor/) for more details on getting started, demo videos, and access to the public Slack channel.

In this task, you will analyze an existing application that has had the Transformation Advisor data collector run against it.  This will prepare you for the subsequent steps of this tutorial to transform the application from it's current WebSphere Application Server Version 7 format to a current WebSphere Liberty application.

1. Access the public Transformation Advisor homepage at [https://lands-ui.mybluemix.net/](https://lands-ui.mybluemix.net/).  Transformation Advisor is also available in the IBM Cloud Private Catalog and can be [deployed into any IBM Cloud Private installation](https://developer.ibm.com/recipes/tutorials/deploying-transformation-advisor-into-ibm-cloud-private/), but we will be using the hosted version running on the IBM Cloud Platform for this tutorial.

   For a generic overview of using Transformation Advisor, you can reference this [recipe](https://developer.ibm.com/recipes/tutorials/using-the-transformation-advisor-on-ibm-cloud-private/) from the developer.ibm.com/recipes site.

2. Enter **purplecompute-tutorial** as the unique identifier here.  A workspace has already been created here, with existing data already uploaded for you to review.  Otherwise, you would have to spend a considerable amount of time setting up a WebSphere Application Server environment, which is most definitely not the goal of this tutorial.

   ![Transformation Advisor 01](/static/imgs/modernize-app-for-was/Source60.png)

3. You can create multiple tasks for different modernization and migration efforts under a given workspace.  For now, you will use the **LibertyTransform** task that has already been created.  Click **LibertyTransform** from the left menu.

   You are presented with the *User Preferences* panel, which asks three questions before configuring the data collector tool:
   * The first question asks *Do you want to move your application to a Private or Public Cloud?*.
   * The second question asks *Do you want to move your application data to the Cloud?*.
   * The third question asks *Do you want your application to run in a flexible environment with a small footprint and rapid start up?*.

   ![Transformation Advisor 02](/static/imgs/modernize-app-for-was/Source61.png)

   Your answers to these three questions configure the data collector to target specific options for migration and relocation of the identified applications.  For this tutorial, the desired options that have been pre-selected are *I don't mind* as the answer to the first question, *No* as the answer to the second question, and *Yes* as the answer to the third question.

4. Click the **Data Collector** tab at the top.  This page details the steps required to download and run the data collector in your local environment.  Since you do not have a local WebSphere Application Server environment as part of this tutorial, you do not need to perform anything on this page as time.  However, you should review the *Tell me more about how this tool works* section once you need to run through Transformation Advisor activities on your own systems.

   ![Transformation Advisor 03](/static/imgs/modernize-app-for-was/Source62.png)

5. Click the **Recommendations** tab at the top.  You will see pre-populated information in this tab already, based on the [Enterprise Application Modernization Reference Architecture](https://github.com/ibm-cloud-architecture/refarch-jee) activities.

   There is an initial dialog, titled **Development Costs**, that you are presented with upon your initial viewing of the Recommendations tab.  Transformation Advisor provides some numerical analysis on how long certain tasks are expected to take, how difficult they are expected to be, and some baseline overhead costs that are assumed in any software migration project.  As the dialog states, these values should be considered in context what the rest of the application analysis results show and should only be used as a guide, not hard and fast expectations.  These values will fluctuate over time and vary across different real-world applications.

   ![Transformation Advisor 04](/static/imgs/modernize-app-for-was/Source63.png)

   Select the *Do not show this again* check box and click **Ok**.

6. Click **Dmgr01** at the top of the page to review the applications from the simulated WebSphere Application Server ND production environment.  You are presented with an initial line-item view of all the EARs, WARs, and JARs that the Transformation Advisor's data collector identified.  You can hover over each of the blue information icons in the column headers for a description of the different types of data the tool has calculated.

   ![Transformation Advisor 05](/static/imgs/modernize-app-for-was/Source64.png)

   * Under the **Recommendation** column, you will see that **Liberty on Private Cloud** has been selected, as that runtime and platform combination aligns most optimally with our answers to the first and third question on the **User Preferences** tab.

   * Under the **Tech Match** column, you will see a 100% rating for our existing application technology to match our new runtime and platform choices.  We will talk more on this later.

   * Under the **Possible Issues** column, you see a series of green, yellow, and red bars.  These are the number of informative, warning, and severe issues identified respectively from the underlying analysis tooling.  Again, this is only a summary here and we will talk more on this later.

   * The next three columns relate back to the information the previous dialog mentioned, regarding development costs.  These columns breakdown the overall expected amount of time-based effort a single engineer would require to perform the migration.  There is an expectation that it would take 1.25 days to perform the necessary application development work, 5 days to perform the necessary environment configuration & deployment, for a total of around 6.25 days worth of total time.

7. Once you are satisfied with understanding each of the columns in the initial table, click **View Details** to be taken to the **Application Details** section lower down on the page.  It is here that you can review all the gathered information from the data collector that made up the numbers in the above summary table.

   ![Transformation Advisor 06](/static/imgs/modernize-app-for-was/Source65.png)

   Under the **Issue** table, you will see the four *Severe* issues at the top.  These are items that are expected when migrating applications between versions with much time lapsed between them.  Some of the work you will do in subsequent steps of the this tutorial will address each of these severe issues, such as confirming correct lookup of Enterprise JavaBeans and providing the necessary runtime libraries that are not packaged in WebSphere Liberty, but were previously packaged in WebSphere Application Server distributions.

   Scrolling down, you will see the nine **Warning** issues identified during the data collector's run.  Many of these issues are systematic of moving between Java versions and have follow-up information if you click on the chevron to the left of each item.  Many of the issues also are visible inside Java IDEs when targeting newer Java versions as a target runtime.  You will work with some of these issues, such as the *Check for behavior change in JPA cascade strategy*, in subsequent steps of this tutorial.

   Finally, you will see the seven **Information** issues identified.  Many of these are general best practices that should be adhered to when moving any application, deploying into a hybrid environment, or adopting a new technology.  You will see more on these issues in the next step.

8. Now that you've reviewed the initial Transformation Advisor results, you should feel pretty confident about the ability to migrate the tutorials WebSphere Application Server Version 7 application to a current version of WebSphere Liberty.  However, as previously noted, Transformation Advisor uses existing tooling to gather some of it's information and those generated results are provided here as well.

   If you are comfortable with what has been presented here so far, you can move on to **Step 2**.  If you would like more information, continue on to the next steps for some deeper insight into the generated documentation from the existing production environment.

9. Click **Analysis Report** at the bottom of the page.  You are presented with a dialog stating that Transformation Advisor uses a dynamic ruleset to evaluate identified issues, which may appear differently than the static ruleset the WAMT tooling uses.  Click **Ok** to move on.

   A new tab opens and you are presented with the raw **Detailed Migration Analysis Report**.  You will first notice a larger number of rules flagged, files affected, and total results in this report than in Transformation Advisor.  This is because Transformation Advisor's ruleset identifies false positives and factors out unnecessary issues, while this reports capture everything regardless of context.

   ![Transformation Advisor 07](/static/imgs/modernize-app-for-was/Source66.png)

   Scrolling down, you can see more detail on some of the previous **Information** items. Scroll down until you see **Databases (2)** and click **Show rule help**.  This will explain that this rule is built around Java code that utilizes `java.sql` and `javax.sql`-associated Classes and Methods.  In the raw report, this is identified as a *Warning*, but Transformation Advisor's ruleset has downgraded this to an *Information*-level warning, as following the rest of the [IBM Cloud Garage Method Architecture Center](https://www.ibm.com/cloud/garage/category/architectures) best practices, this requirement will be easily met.  Click **Show results** to see which classes inside our application are actually accessing the necessary database backends.

   Once you are satisfied with reviewing the raw report, close the current tab and return to Transformation Advisor.

10. Next, click **Technology Report** for an understanding into how the **Tech Match** column was calculated.

   This new report is opened to show all the permutations of technology identified inside of the Customer Order Serivces applicatio, including JAX-RS, EJB, JPA, JDBC, other JEE specifications, along with their compatibility across the different available runtimes across the WebSphere family.  These runtimes include Liberty on Bluemix Instant Runtimes, Liberty on Containers & Virtual Machines, traditional WebSphere on Virtual Machines, and both Liberty & traditional WebSphere on z/OS.  The Customer Order Services application is pretty compatible with wherever you'd like to take it, so additional extra credit work can be performed to move it to any of the other runtime/platform columns of your choice.

   ![Transformation Advisor 08](/static/imgs/modernize-app-for-was/Source67.png)

   Once you are satisfied with reviewing the raw report, close the current tab and return to Transformation Advisor.

11. To review the final report generated by Transformation Advisor's analysis, click **Inventory Report** to understand the detailed contents of the application binaries.

   You are presented with the raw **Application Inventory Report**.  This report gives all the fine-grained details of what is included in the applications identified by Transformation Advisor's data collector.  Many Enterprise applications have been built over the course of many years and in the hands of many different teams.  This report helps to identify specific types of Java objects, resources, and artifacts in a given application, interaction across modules, and the provenance of certain libraries - across core Java libraries, Open Source Software, WebSphere, and others.

   ![Transformation Advisor 09](/static/imgs/modernize-app-for-was/Source68.png)

   Once you are satisfied with reviewing the raw report, close the current tab and return to Transformation Advisor.

You have now walked through the Transformation Advisor analysis of **Customer Order Services** and are ready to transform the application to run on WebSphere Liberty and IBM Cloud Private.

## Install WebSphere Application Server Liberty locally

The IBM WebSphere Application Server Liberty can be installed from eclipse. Since we will also need to configure eclipse to use IBM WebSphere Liberty Server as the targeted runtime, we will then do both from eclipse at once.

1. [Open a terminal window](troubleshooting.md#open-the-terminal).

2. Open eclipse by typing the following on the terminal

   ```
   cd ~/PurpleCompute/eclipse
   ./eclipse
   ```

   select the default workspace by clicking OK

   ![Source migration 48](/static/imgs/toLiberty/Source48.png)

3. If a Welcome page is displayed, close it.

4. At the bottom, select the servers tab and click on the _"No servers available..."_ message.

   ![Source migration 49](/static/imgs/toLiberty/Source49.png)

5. On the new server dialog that pops up, type in _liberty_ so that available servers get filtered. Then, select Liberty Server and leave the rest as is. Click Next.

   ![Source migration 50](/static/imgs/toLiberty/Source50.png)

6. Set the path for the existing installation to `/home/skytap/PurpleCompute/wlp`. Click Next.

   ![Source migration 51](/static/imgs/toLiberty/Source51.png)

7. On the next window, leave all the options as they are (see picture below) and click on Finish.

   ![Source migration 52](/static/imgs/toLiberty/Source52.png)

8. You should now see your Liberty Server at localhost created in the Servers tab at the bottom and a project that stores the configuration for your server on the left in the Enterprise Explorer tab.

   ![Source migration 53](/static/imgs/toLiberty/Source53.png)

9. Double click on the newly created Liberty Server at localhost in the Servers view and set the start timeout value for the Liberty server to something around 180 or over _(if the timeout is too small you might see an error saying that the Server Liberty Server at localhost was unable to start within XX seconds)_

   ![Source migration 61](/static/imgs/toLiberty/Source61.png)

10. Click on Save (Ctrl+s)

   ![Source migration 63](/static/imgs/toLiberty/Source63.png)

## Get the code

The migration toolkit is eclipse based. Therefore, these are the steps to be taken to get the code into eclipse to run the migration toolkit on it:

1. [Open a terminal window](troubleshooting.md#open-the-terminal).

2. Download Customer Order Services application's source code from GitHub

   ```
   cd ~/PurpleCompute/git
   git clone https://github.com/ibm-cloud-architecture/refarch-jee-customerorder.git
   ```
   ![Source migration 35](/static/imgs/toLiberty/Source35.png)

3. Switch to the WAS 7 development branch

   ```
   cd refarch-jee-customerorder
   git checkout was70-dev
   ```
   ![Source migration 36](/static/imgs/toLiberty/Source36.png)

4. Go back to eclipse (should still be open since last section)

5. Import projects

   1. Hover the black header of eclipse at the top to get the eclipse menu bar to show up and click on File --> Import...

   ![Source migration 64](/static/imgs/toLiberty/Source64.png)

   2. On the dialog that pops up, select _General_ folder, then _Existing Projects into Workspace_ and click Next.

   ![Source migration 37](/static/imgs/toLiberty/Source37.png)

   3. In the next dialog, click on _Browse..._ and navigate to `/home/skytap/PurpleCompute/git/refarch-jee-customerorder` for the root directory containing all projects and click OK.

   ![Source migration 38](/static/imgs/toLiberty/Source38.png)

   4. Eclipse will directly detect all the projects within that folder and select them all. Click Finish.

A migration dialog will pop up after importing the projects into the eclipse workspace since eclipse will detect such projects are configured to run on a runtime that it is not aware of. As a result, it pops up with a workspace migration dialog.

![Source migration 39](/static/imgs/toLiberty/Source39.png)

Disregard this piece of advice by clicking on Cancel.

In the migration cancel window, click OK. The runtime migration will be done in the following sections.

![Source migration 65](/static/imgs/toLiberty/Source65.png)

Finally, prevent eclipse from automatically building your projects any time a change is made (this will improve eclipse performance). Click on Project at the eclipse top bar menu and deselect the Build Automatically option.

![Source migration 66](/static/imgs/toLiberty/Source66.png)

## Set up your development environment

When we use/create a new development environment, it is most likely that we will need to tidy it up a bit since installation paths, development tools versions, libraries and things like that might very well be different from the original development environment.

As you can see when you import the projects into eclipse, we get those projects with red error marks.

![Source migration 40](/static/imgs/toLiberty/Source40.png)

In order to see what the problems in your workspace are, you can open the problems view by clicking on Window --> Show View --> Other... at the eclipse top bar menu.

![Source migration 67](/static/imgs/toLiberty/Source67.png)

Then, type into the text bar Problems to filter out all views, select Problems view and click OK.

![Source migration 68](/static/imgs/toLiberty/Source68.png)

You should now see the Problems view at the bottom where you can browse in order to find more detail about the current problems in your eclipse workspace.

![Source migration 54](/static/imgs/toLiberty/Source54.png)

If you do so, you should be able to find errors for each of the projects regarding the build path among many other problems. That is, the references to the Java Runtime Environment and WebSphere libraries we have in our projects need to be updated for our new development environment. This should be the first step of all, since a project must have a correct build path to be built (and potentially uncover new issues).

In order to update your JRE and WebSphere libraries references, right click on a project and click on Build Path --> Configure Build Path...

![Source migration 69](/static/imgs/toLiberty/Source69.png)

Once the properties dialog opens up, click on the Libraries tab. You should now see something similar to the following:

![Source migration 41](/static/imgs/toLiberty/Source41.png)

We then need to fix the paths for the two **unbound** libraries which are the JRE System Library and the Server Library. As you can see, both are yet pointing to the WebSphere Application Server traditional V7.0 libraries from the old/original development environment. To update those libraries to point to the appropriate path in your new development environment, you need to select each of the libraries and click on the Edit... button on the right hand side of this dialog.

For the JRE System Library, select the last option which says Workspace default JRE and click Finish.

![Source migration 42](/static/imgs/toLiberty/Source42.png)

For the Server Library, repeat the steps but select the Liberty Runtime option and click Finish.

![Source migration 43](/static/imgs/toLiberty/Source43.png)

Click OK to close the properties window.

**IMPORTANT: Make sure you have fixed the build path for CustomerOrderServices, CustomerOrderServicesWeb and CustomerOrderServicesTest projects**

After updating the references to our actual WebSphere Server and JRE System libraries, we should clean and rebuild the entire workspace. For doing so, click on Project --> Clean... at the eclipse top bar menu

![Source migration 70](/static/imgs/toLiberty/Source70.png)

On the Clean dialog that opens up, verify that the Clean all projects and build the entire workspace options are selected and click OK.

![Source migration 45](/static/imgs/toLiberty/Source45.png)

If we now check the Problems view out again, we might very well see many more problems. The reason for this is that projects are now getting built as a result of a correct build path:

![Source migration 55](/static/imgs/toLiberty/Source55.png)

However, if we dobule click on a couple of those different errors we see in the Problems view, we realise that these errors happen as a result of missing third party libraries:

![Source migration 56](/static/imgs/toLiberty/Source56.png)

![Source migration 57](/static/imgs/toLiberty/Source57.png)

In our case, we are getting errors because we are missing the Java EE 6 rest services technology library needed for the compilation of our code. This technology comes as a library called JAX-RS and the Java EE 6 version of it is 1.1. Neither the JRE version we have installed on our system nor the WebSphere Application Server Liberty server, which we have just set our projects to get built with few steps above, come with the needed JAX-RS library out of the box.

However, WebSphere Application Server Liberty is a composable lightweight server which you need to add features to in order to get the Liberty server to support certain functionality and technologies. Therefore, if we want to run an application that uses JAX-RS 1.1 technology we need to add/install the JAX-RS 1.1 feature/library to our WebSphere Application Server Liberty server. This will also make the JAX-RS 1.1 library available for compilation.

To install the JAX-RS 1.1 functionality to our WebSphere Application Server Liberty server execute on any available terminal window (or open a new one):

```
~/PurpleCompute/wlp/bin/installUtility install jaxrs-1.1
```

If the installation is successful, you should see the following on your terminal window.

![Source migration 58](/static/imgs/toLiberty/Source58.png)

More about what technologies WebSphere Application Server Liberty supports and comes with out of the box as well as how to get these installed/added to your WebSphere Application Server Liberty on the [Configure WebSphere Liberty Server - features](#1-features) section below.

After installing any new feature/JEE feature to our WebSphere Application Server Liberty, we must clean and build the workspace now that we have the appropriate third party JAX-RS libraries. First, click on File --> Refresh at the eclipse top bar menu.

![Source migration 71](/static/imgs/toLiberty/Source71.png)

 Then, clean and rebuild your projects again by clicking on Project --> Clean... at the eclipse top bar menu, verifying that Clean all projects and Build the entire workspace are both selected and clicking OK.

If we look now to the Problems view, we should see many less problems:

![Source migration 44](/static/imgs/toLiberty/Source44.png)

However, we still see problems. In this case, we want to sort out the Xpath is invalid error. To sort it out, right click on CustomerOrderServicesWeb project (which is where these errors are found) on the left hand side Enterprise Explorer widget, and select Properties at the bottom.

![Source migration 72](/static/imgs/toLiberty/Source72.png)

On the properties dialog, select Validation on the left hand side, scroll down to the last validator, which is XSL Validator, and right click on it. Deselect both Manual and Build options.

![Source migration 46](/static/imgs/toLiberty/Source46.png)

Click Apply and OK. Finally, clean and build the workspace as already done in previous steps. You should now see only Target runtime and one JPA related (library provider) errors which we will get fixed in the next section.

![Source migration 73](/static/imgs/toLiberty/Source73.png)

**Conclusion:** As we could see in the above walk through, when we move to a different/new development environment we will need to plan ahead and bear in mind that some time will be needed for setting up your new development environment. Even more if this new environment will be used for a WebSphere Application Server migration.

### Recreate Db2 Datastore on ICP

As the original application database resides on-premise, it will need to be recreated inside the IBM Cloud Private (ICP) environment for intial testing.  For production-level use cases, external integration of existing databases into any given IBM Cloud Private environment is possible, with the help of the services such as the IBM Cloud Platform Secure Gateway service.  However, for this tutorial, the application database will be run from inside the ICP environment for ease of interaction.

#### Create a storage volume for Db2 Helm Chart

To utilize the Db2 database provided for IBM Cloud Private, a persistent volume needs to first be created.  Depending upon multiple platform configuration options, this can be done automatically, but in the effort of learning, this tutorial covers the manual creation of this artifact.  This helps to reinforce the mapping of the service to its requirements.

1. [Log into the ICP](troubleshooting.md#log-into-icp).

2. Click **Create resource** button on the top right corner.

   ![Source migration 93](/static/imgs/toLiberty/Source93.png)

3. A window to define your new resource will pop up. Delete the pre-filled content in the dialog box and replace it with the following snippet:
   ```
   apiVersion: v1
   kind: PersistentVolume
   metadata:
    name: customerorder-pv
   spec:
    capacity:
      storage: 2Gi
    accessModes:
      - ReadWriteOnce
    hostPath:
      path: /home/skytap/PurpleCompute/persistent_volumes/customerorder-data
      type: DirectoryOrCreate
   ```
   This YAML block will create a *PersistentVolume* which the Db2 Helm Chart will create a *PersistentVolumeClaim* against.  In doing so, Db2 can now persist its data across individual container instances should one crash, fail, or otherwise be removed.

   As this is an introductory tutorial, we are using the most simplistic form of shared storage in a Kubernetes-based environment, *hostPath*.  This allows Kubernetes to save data from containers running in Pods to the physical host.  But note that this is not shared across hosts automatically, so should the container fail and be rescheduled on a different host, this data would be unavailable.  For this tutorial, this is acceptable.

4. Click **Create**.

#### Deploy the Db2 Helm Chart

1. On the ICP web based console, click the hamburger menu icon and select **Catalog** > **Helm Charts**.

   ![Source migration 75](/static/imgs/toLiberty/Source75.png)

2. Select **ibm-db2oltp-dev** from the list of available Helm charts.

   ![Source migration 76](/static/imgs/toLiberty/Source76.png)

3. Review the presented documentation for the IBM Db2 Developer-C Helm Chart and click **Configure** at the very bottom.
4. In the *Configuration* section, enter a **Release name** (preferably with only lower-case letters and hyphens - this tutorial will use **db2-cos**) and select the **Target namespace** of *purplecompute*.
    ![Db2 setup 01](/static/imgs/db2-on-icp/db2Setup01.png)
5. In the *Docker image configuration* section,
    * Make sure **Docker Repository** and **tag** fields get values **na.cumulusrepo.com/hcicp_dev/db2server_dec** and **11.1.2.2b** respectively. The reason for this is that the Skytap image you are working on comes with that DB2 Docker image pre-pulled so that you don't need to go off to the internet to pull it down.
    * Follow the [link](http://ibm.biz/db2-dsm-license) in the **secret** field to retrieve a validated image secret.  Copy and paste this value from the other browser window into this entry field.
    ![Db2 setup 02](/static/imgs/db2-on-icp/db2Setup02.png)
    ![Db2 setup 02b](/static/imgs/db2-on-icp/db2Setup02b.png)
6. In the *Db2 instance configuration* section, enter a username (defaults to **admin**) and a password (this tutorial will use **passw0rd**).  Note that the password defaults are randomly generated, so you will need to provide a known password here.
    ![Db2 setup 03](/static/imgs/db2-on-icp/db2Setup03.png)
7. In the *Database configuration options* section, enter **ORDERDB** in the *Database Name* field.
8. In the *Data volume configuration* section, update the *Size of the volume claim* field to be **2Gi**.  Kubernetes will automatically map the creation of a new PersistentVolumeClaim to the PersistentVolume created in the previous section.
    ![Db2 setup 04](/static/imgs/db2-on-icp/db2Setup04.png)
9. In the *Resource configuration* section, update the *Memory limit* field to be **8Gi**.
    ![Db2 setup 05](/static/imgs/db2-on-icp/db2Setup05.png)
10. Click **Install**.
11. Once the Helm installation is underway, click **View Helm Release** on the dialog.

#### Validate Db2 Helm Chart deployment

It will take a few minutes to deploy the Db2 Helm chart, especially if this is the first time in the ICP instance that Db2 is being installed, as the image needs to be downloaded to the ICP registry first. After about 5-10 minutes, the following commands can be use to validate the successful deployment of the Db2 Helm chart.

On a [terminal window](troubleshooting.md#open-the-terminal) where the [Kubernetes CLI has been configured on](troubleshooting.md#configure-the-kubernetes-cli),

1. To view the list of all deployed Helm charts on the current ICP installation, run `helm list`:

   ```
   skytap@icpboot:~$ helm list
   NAME   	REVISION	UPDATED                 	STATUS  	CHART                 	NAMESPACE    
   db2-cos	1       	Tue Feb 13 07:43:39 2018	DEPLOYED	ibm-db2oltp-dev-1.1.1 	purplecompute
   ta-cos 	1       	Tue Feb 13 02:08:05 2018	DEPLOYED	ibm-transadv-dev-1.3.0	purplecompute
   ```
2. To view a consolidated set of Kubernetes resources that a given Helm chart deployment is utilizing, run `helm status {release_name}`.

   ```
   skytap@icpboot:~$ helm status db2-cos
   LAST DEPLOYED: Tue Feb 13 07:43:39 2018
   NAMESPACE: purplecompute
   STATUS: DEPLOYED

   RESOURCES:
   ==> v1/Secret
   NAME                                TYPE                     DATA  AGE
   db2-cos-ibm-db2oltp-dev-db2-secret  kubernetes.io/dockercfg  1     10m
   db2-cos-ibm-db2oltp-dev             Opaque                   1     10m

   ==> v1/PersistentVolumeClaim
   NAME                               STATUS  VOLUME            CAPACITY  ACCESSMODES  STORAGECLASS  AGE
   db2-cos-ibm-db2oltp-dev-data-stor  Bound   customerorder-pv  2Gi       RWO          10m

   ==> v1/Service
   NAME                     CLUSTER-IP  EXTERNAL-IP  PORT(S)                          AGE
   db2-cos-ibm-db2oltp-dev  10.1.0.218  <nodes>      50000:30494/TCP,55000:30428/TCP  10m

   ==> v1beta1/Deployment
   NAME                     DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
   db2-cos-ibm-db2oltp-dev  1        1        1           0          10m


   NOTES:
   1. Get the database URL by running these commands:
    export NODE_PORT=$(kubectl get --namespace purplecompute -o jsonpath="{.spec.ports[0].nodePort}" services db2-cos-ibm-db2oltp-dev)
    export NODE_IP=$(kubectl get nodes --namespace purplecompute -o jsonpath="{.items[0].status.addresses[0].address}")
    echo jdbc:db2://$NODE_IP:$NODE_PORT/sample
   ```

3. To monitor the underlying Kubernetes Deployment artifact, run `kubectl get deployment -w`.  The `-w` parameter is important, as the CLI will actively monitor the status of Kuubernetes (and specifically the Deployments) and report back any changes to the CLI.

   ```
   skytap@icpboot:~$ kubectl get deployment -w
   NAME                              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
   db2-cos-ibm-db2oltp-dev           1         1         1            0           10m
   ta-cos-ibm-transadv-dev-couchdb   1         1         1            1           5h
   ta-cos-ibm-transadv-dev-server    1         1         1            1           5h
   ta-cos-ibm-transadv-dev-ui        1         1         1            1           5h
   ```

4. Once the *AVAILABLE* field turns to **1**, the Db2 instance is available and ready to be used.

#### Bootstrap initial data into database

Once Db2 is up and running inside ICP, there are many ways to now get data into that database. The preferred Kubernetes approach would be to create a [Job](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/) that would run once and bootstrap the data automatically. We provide you with this job definition for this tutorial.

On a terminal window where the [Kubernetes CLI has been configured on](troubleshooting.md#configure-the-kubernetes-cli):

1. Download the job definition that populates your newly created database. On a terminal window, execute:

    `pushd /tmp && wget https://raw.githubusercontent.com/ibm-cloud-architecture/refarch-jee/master/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/populate_cos_db.yaml`

2. Create the Kubernetes job out of the definition you just pulled down

    `kubectl create -f populate_cos_db.yaml`

    **IMPORTANT:** the populate_cos_db.yaml job definition uses the db2 default values for this tutorial from the above sections. If you decided to change these, please also update the populate_cos_db.yaml job definition accordingly.

3. Watch for the job to succeed

    `kubectl get jobs -w`

    Once **SUCCESSFUL** turns to 1, the DB should be populated.

    ```
    skytap@icpboot:/tmp$ kubectl get jobs -w
    NAME                  DESIRED   SUCCESSFUL   AGE
    populate-cos-db       1         1            2m
    ```
The application's data store is now available to be used by the updated Liberty-based application running on ICP.

## Source Code Migration

In order to migrate the code to get our WebSphere Application Server 7 application working on WebSphere Liberty, we are going to use the [WebSphere Application Server Migration Toolkit (WAMT)](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Application_Server_Migration_Toolkit). The migration toolkit provides a rich set of tools that help you migrate applications from third-party application servers, between versions of WebSphere Application Server, to Liberty, and to cloud platforms such as Liberty for Java on IBM Bluemix, IBM WebSphere on Cloud and Docker.

### Software Analyzer Configuration

More precisely, we are going to use the Software Analyzer that the WAMT comes with. For doing so, we first need to have eclipse on our development environment with the WAMT installed on it and our WAS 7 application projects imported into the workspace. This should be the state we were at before we temporarily moved on to create our db2 datastore.

If you closed eclipse,

1. [Open a terminal window](troubleshooting.md#open-the-terminal):

2. Open eclipse by typing the following on the terminal

   ```
   cd ~/PurpleCompute/eclipse
   ./eclipse
   ```

   select the default workspace by clicking OK

   ![Source migration 48](/static/imgs/toLiberty/Source48.png)

3. If a Welcome page is displayed, close it.

Now, to open the Software Analyzer and configure it,

1. Click on **Run -> Analysis...** on the eclipse top bar menu.

   ![Source migration 77](/static/imgs/toLiberty/Source77.png)

   This will open the **Software Analyzer**.

   ![Source migration 1](/static/imgs/toLiberty/Source1.png)

2. Right click on _Sofwtare Analyzer_ and select **New**. Give a relevant and appropriate name to the new configuration and click on the **Rules** tab for this configuration. Select the **WebSphere Application Server Version Migration** option for the _Rule Sets_ dropdown menu and click **Set...**  If this step is already completed for you, just select the Rule set and examine the details.

   ![Source migration 2](/static/imgs/toLiberty/Source2.png)

3. The Rule set configuration panel should be displayed. This panel must be configured so that the appropriate set of rules based on our migration requirements are applied during the software analysis of our applications. Configure it as the image below shows and click OK when done.

   ![Source migration 3](/static/imgs/toLiberty/Source3.png)

4. Finally, click Analyze.

### Run the Software Analyzer

After running the _Software Analyzer_ you should see a _Software Analyzer Results_ tab at the bottom. The Software Analyzer rules are categorised, and so are the errors and warnings produced in its report, in four categories: **Java Code Review, XML File Review, JSP Code Review and File Review**. We must go through each of these tabs/categories and review the errors and warnings as code/configuration changes might be needed.

![Source migration 4](/static/imgs/toLiberty/Source4.png)

#### 1. File Review

We will start off with the **File Review** analysis tab. As you can see in the image below, one warning that will always appear when you migrate your apps to a newer WebSphere Application Server version is the need to configure the appropriate target runtime for your applications. This is the first and foremost step:

![Source migration 5](/static/imgs/toLiberty/Source5.png)

> **FYI:** Along with the warning and errors reported, the WebSphere Application Migration Toolkit also comes with information about the rule that flagged each error/warning and the possible solutions for them. In order to see this info and help, click on Help -> Show Contextual Help at the eclipse top bar menu. This will open the help widget in eclipse on the right hand side.

   ![Source migration 78](/static/imgs/toLiberty/Source78.png)

> Click again on the error/warning displayed at the bottom in eclipse in the Software Analyzer tab in order to load the information for such error/warning on the help widget we have just opened. If the information presented on this widget is still not enough or want more details on the error/warning, scroll down and click on Detailed help

   ![Source migration 6](/static/imgs/toLiberty/Source6.png)

> The Detailed help link should open a web-based information centre with a longer and more detailed explanation of the error/warning and show you additional ideas on how to resolve that problem.

   ![Source migration 7](/static/imgs/toLiberty/Source7.png)

> If the Detailed help does not open on your web browser and instead displays in the eclipse Help widget but you prefer to see this information on your web browser for a better reading, you need to configure eclipse to do so. Open eclipse preferences by clicking on Window --> Preferences at the eclipse top bar menu

   ![Source migration 90](/static/imgs/toLiberty/Source90.png)

> Then click on Help on the left hand side options list and set the Open help view documents to **in a browser** as the following image depics

  ![Source migration 91](/static/imgs/toLiberty/Source91.png)

As we could read above on the detailed information displayed for this error/warning the WAMT has found:

_"To resolve this issue, right-click the project in Project Explorer or Package Explorer and select Properties then Targeted Runtimes. Select the target application server and click Apply. If the target application server is not displayed in the list of available target runtimes, click New to add the server runtime environment to the workspace."_

![Source migration 8](/static/imgs/toLiberty/Source8.png)

If we follow the instructions above, we still don't see the Liberty Runtime displayed. However, if we click on the Show all runtimes checkbox we see it listed but greyed out (disabled) so we know the Liberty Runtime is, at least, installed on the system.

![Source migration 9](/static/imgs/toLiberty/Source9.png)

As you can read in the image above, the reason for the Liberty runtime to be disabled is that we might need to uninstall one or more of the currently installed project facets. This information also appeared on the web-based information centre the detailed help link in the help widget opened for this error/warning we selected down at the bottom in the Software Analyzer tab. It actually said:

_"When you migrate from WebSphere traditional to Liberty, the Liberty server might be hidden from view because of WebSphere traditional project facets that are configured on the project. Select Project facets and remove any project facets that are related to WebSphere traditional. You can then select the Liberty server in the Targeted Runtimes panel."_

To uninstall those WebSphere traditional project facets, we could either click on the Uninstall Facets... link displayed at the bottom of the Targeted Runtimes dialog or click on the Project Facets option on the option list displayed on the left hand side of the current window. We choose clicking on the Uninstall Facets... link. The following dialog/window should display:

![Source migration 10](/static/imgs/toLiberty/Source10.png)

Once you have deselected all active WebSphere (Version 7.0) specific facets installed for the project (red square on the image above), click on Finish. You will get back to the targeted runtimes panel but you will not yet see the Liberty Runtime option available to select until you click on Apply. Hence, click on Apply, deselect the existing WebSphere Application Server traditional V7.0 option, select the Liberty Runtime option and click on Apply and OK.

![Source migration 11](/static/imgs/toLiberty/Source11.png)

**IMPORTANT:** Repeat the process of uninstalling the old WebSphere Application Server V7.0 project facets and selecting the Liberty Runtime as targeted runtime for all four projects.

If we ran the Software Analyzer again, we should see the File Review tab empty.

![Source migration 79](/static/imgs/toLiberty/Source79.png)

Also, if we clean and build the projects again (click on project --> clean... at the eclipse top bar menu) we should see no errors anymore in the problems tab at the bottom.

#### 2. Java Code Review

Moving on to the **Java Code Review** category tab within the Software Analyzer widget down at the bottom, these are the aspects the WebSphere Application Migration Toolkit (WAMT) warns us about:

![Source migration 12](/static/imgs/toLiberty/Source12.png)

Let's go over each of them to see what needs to change.

The first error has to do with a behavior change on the lookups for Enterprise JavaBeans in Liberty. If we click on it, we read the following on the help widget:

![Source migration 80](/static/imgs/toLiberty/Source80.png)

Again, we need to click on the Detailed help link in order to read a comprehensive explanation of the error flagged:

![Source migration 17](/static/imgs/toLiberty/Source17.png)

Then, it appears that we might have an issue on how we are doing the lookups for Enterprise JavaBeans with regards to the JNDI namespaces we are doing them into. To see exactly how we are doing these lookups we can double click on any of the files displayed under this error in the Software Analyzer widget down at the bottom so that it gets open:

![Source migration 81](/static/imgs/toLiberty/Source81.png)

We effectively see that we are using **ejblocal** for doing the JNDI lookups which is not valid anymore for the Liberty Server since they need to use the portable JNDI syntax as we could read in the Detailed help document above. As a result, we need to change these on the three java files flagged by the Software Analyzer. They all belong to the **CustomerOrderServicesWeb** project:

![Source migration 27](/static/imgs/toLiberty/Source27.png)

We need to change the context lookups on each of the files above with the following context lookups definitions **respectively**:

```
java:app/CustomerOrderServices/ProductSearchServiceImpl!org.pwte.example.service.ProductSearchService
java:app/CustomerOrderServices/CustomerOrderServicesImpl!org.pwte.example.service.CustomerOrderServices
java:app/CustomerOrderServices/ProductSearchServiceImpl!org.pwte.example.service.ProductSearchService
```

Once you have changed the context lookups for the Enterprise JavaBeans in each of the files, click on save for all.

The second item the Software Analyzer flags for the Java Code Review category is a warning about the type the initialContext lookup method may return. We click on this item to see that the help widget on the right hand side says:

![Source migration 82](/static/imgs/toLiberty/Source82.png)

So we are being warned that on Liberty Server the type returned by the initialContext lookup method might be a primitive data type and not a String as it used to be in traditional WebSphere. Again, we double click on any of the files listed under this warning in the Software Analyzer widget to see how we are treating the returned object by the aforementioned method:

![Source migration 83](/static/imgs/toLiberty/Source83.png)

We see that we are doing a _(Context)_ type casting to whatever the initialContext lookup method returns so that we make sure we are treating that object appropriately. As a result, we do not need to take any action on this warning.

Moving on to the third item the Software Analyzer flags, we see a warning about using the default initalContext JNDI properties. In order to understand more about the problem, we, again, click on it and read what the Help widget says about it:

![Source migration 84](/static/imgs/toLiberty/Source84.png)

Since there isn't much information on this Help widget, we click on the Detailed help link:

![Source migration 13](/static/imgs/toLiberty/Source13.png)

Now that we have understood what the problem is, we double click on the file pointed out by the Software Analyzer to inspect its code:

![Source migration 14](/static/imgs/toLiberty/Source14.png)

As you can see by looking at the code, we are not using any of the two default initialContext JNDI properties this warning is about so we do not need to care about their default values. As a result, we can ignore this warning and move on to the next one.

Next aspect in this Java Code Review section is about the use of system-provided third-party APIs:

![Source migration 18](/static/imgs/toLiberty/Source18.png)

If we click on the Detailed help within the Help widget on the right hand side, we are presented with the following information:

![Source migration 19](/static/imgs/toLiberty/Source19.png)

However, that still does not seem like enough information in order to figure out what the problem is. Therefore, we click on the link at the bottom oh this Detailed help window which get us to the following IBM Knowledge Center page for WebSphere:

![Source migration 20](/static/imgs/toLiberty/Source20.png)

With the information gathered along the links we have visited above, we now realise we need to configure the Liberty server to be able to allow the application access to third-party libraries. We do so by adding the following to the **server.xml** configuration file (**this will be done in the next** [**Configure the Liberty Server**](#configure-the-liberty-server) **section**):

```
<application id="customerOrderServicesApp" name="CustomerOrderServicesApp.ear" type="ear" location="${shared.app.dir}/CustomerOrderServicesApp.ear">
     <classloader apiTypeVisibility="spec, ibm-api, third-party" />
</application>
```

The above will allow the classloader to have access to the third-party libraries included with Liberty. Some of those third-party libraries we need the classloader to have access to so that our application work fine are Jackson and Apache Wink libraries.

Finally, the last aspect in this Java Code Review section has to do with a change in the JPA cascade strategy. Once again, we click on the Detailed help link within the Help widget on the right which displays the following information:

![Source migration 15](/static/imgs/toLiberty/Source15.png)

As we can read above, the change in the JPA cascade strategy is not expected to affect most applications. Also, this new cascade strategy can be mitigated by simply reverting to the previous behaviour by setting the _openjpa.Compatibility_ property in the _persistence.xml_ file. Anyway, newer WebSphere Application Server versions can always be configured to run on previous or older version for most of the JEE technologies. JPA is one of them and you can see in the server.xml file that we are using tje jpa-2.0 feature so that the warning above does not affect our app at all.

#### 3. XML File Review

This last section in the Software Analyzer results (JSP Code Review category is empty), we see a problem due to a behaviour change on lookups for Enterprise JavaBeans:

![Source migration 16](/static/imgs/toLiberty/Source16.png)

And this is what the Detailed help says about it (same as before in this Run Software Analyser section):

![Source migration 17](/static/imgs/toLiberty/Source17.png)

This time, the Enterprise JavaBeans lookup is being done on a different file (an XML file rather than a java file). Hence the reason this same problem is displayed in different categories within the Software Analyzer. If we double click on the file that this error is being detected in, we realise we are using the WebSphere Application Server traditional namespaces for the EJB binding here too:

![Source migration 34](/static/imgs/toLiberty/Source34.png)

Therefore, the solution is again to change the lookup to:

```
java:app/CustomerOrderServices/ProductSearchServiceImpl!org.pwte.example.service.ProductSearchService
```

Save and close the file.

At a first pass, we seem to **have completed the review** of all the issues the Software Analyser the WebSphere Application Migration Tool have been able to find. We can now move to see what we need to do in order to configure our WebSphere Liberty server to properly run our Customer Order Services application.

## Configure WebSphere Liberty Server

The IBM WebSphere Application Server Liberty Profile is a composable, dynamic application server environment that supports development and testing of Java EE Full Platform web applications.

The Liberty profile is a simplified, lightweight development and application runtime environment that has the following characteristics:

* Simple to configure. Configuration is read from an XML file with text-editor-friendly syntax.
* Dynamic and flexible. The run time loads only what your application needs and recomposes the run time in response to configuration changes.
* Fast. The server starts in under 5 seconds with a basic web application.
* Extensible. The Liberty profile provides support for user and product extensions, which can use System Programming Interfaces (SPIs) to extend the run time.

[Here](https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_feat.html) you can see the technologies that the WebSphere Application Server Liberty support on its different flavors.

The application server configuration is described in a series of elements in the **server.xml** configuration file. We are now going to see what we need to describe in that server.xml configuration file to get our Liberty server prepared to successfully run our Customer Order Services application.

In this section, we are going to see the different configuration pieces for the Liberty server to run the Customer Order Services application. As said above, this is done by editing the server.xml file which lives in `/home/skytap/PurpleCompute/wlp/usr/servers/defaultServer`.

You can manually edit this server.xml file yourself using your preferred editor or you can also do so in eclipse:

![Source migration 47](/static/imgs/toLiberty/Source47.png)

<sup>*</sup>Also, **you can directly replace your existing server.xml file with an already configured server.xml version** that can be found [here](tutorialConfigFiles/server.xml.step1) and just read through the below explanation of it for your information.

#### 1. Features

First of all, we need to identify the Java EE features we want our Liberty server to provide us with in order to run our application. In our Customer Order Services application, the main Java EE features we use are:

* JPA
* JAX-RS
* SERVLET
* EJB
* JDBC
* JSON
* JAAS

We need to define all these features in the _featureManager_ section within the server.xml configuration file so that the WebSphere Application Server Liberty server loads them during its startup and make them available to your application. As mentioned earlier, WebSphere Application Server Liberty is dynamic and flexible. That is, the run time loads only what your application needs and recomposes the run time in response to configuration changes.

```
<!-- Enable features -->
<featureManager>
    <feature>jpa-2.0</feature>
    <feature>jaxrs-1.1</feature>
    <feature>jsonp-1.0</feature>
    <feature>servlet-3.1</feature>
    <feature>jdbc-4.1</feature>
    <feature>ejbLite-3.1</feature>
    <feature>appSecurity-2.0</feature>
    <feature>localConnector-1.0</feature>
</featureManager>
```

However, we need to install such features in order for the Liberty server to load them and make them available to the app for it to run correctly. **We will explain how to install all the features above at the end of this**

**Extra info:**

If you want to check all the features your WebSphere Application Server Liberty server has installed at any point you can run on a [terminal window](troubleshooting.md#open-the-terminal):

`~/PurpleCompute/wlp/bin/featureManager featureList feature_report.xml`

and a *feature_report.xml* file will be created with a list of all the features your Liberty server comprises of. For an quicker and easier first look you can then execute

`cat ~/PurpleCompute/wlp/bin/feature_report.xml | grep "feature name="`

and you will see an output similar to the following which lists the features WebSphere Application Server Liberty server comes with out of the box

![Source migration 59](/static/imgs/toLiberty/Source59.png)

<sup>*</sup>*We can see in the list above that the jaxrs-1.1 feature does not come installed out of the box and that is the reason for the errors we saw in previous [Set up your development environment](#set-up-your-development-environment) section. If you need to manually install features to your WebSphere Application Server Liberty server check the [installUtility command](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_command_installutility.html)*

#### 2. Application

Add the following lines to your server.xml file to tell the Liberty server what application to run and their class loaders:

```
<!-- Define application and its classloaders -->
<application id="customerOrderServicesApp" location="${shared.app.dir}/CustomerOrderServicesApp.ear" name="CustomerOrderServicesApp.ear" type="ear">
    <classloader apiTypeVisibility="spec, ibm-api, third-party"/>
</application>
```

#### 3. Http Endpoint

Add the following lines to your server.xml file to tell the Liberty server what is going to be the http endpoint for the Customer Order Services web application:

```
<!-- To access this server from a remote client add a host attribute to the following element, e.g. host="*" -->
<httpEndpoint host="*" httpPort="9081" httpsPort="9444" id="defaultHttpEndpoint"/>
```

#### 4. Application security

Add the following lines to your server.xml file to set you application security so that only secure users can access the application:

```
<!-- User and group security definitions -->
<basicRegistry id="basic" realm="customRealm">
    <user name="rbarcia" password="bl0wfish"/>
    <group name="SecureShopper">
        <member name="rbarcia"/>
    </group>
</basicRegistry>
```

#### 5. Data sources

Add the following lines to your server.xml file to define your application data sources as well as what JDBC drivers and properties the Liberty server needs to use in order to access the application's data.

```
<!-- DB2 library definition -->
<library apiTypeVisibility="spec, ibm-api, third-party" id="DB2JCC4Lib">
    <fileset dir="/home/skytap/PurpleCompute/db2lib" includes="db2jcc4.jar db2jcc_license_cu.jar"/>
</library>

<!-- Data source definition -->
<dataSource id="OrderDS" jndiName="jdbc/orderds" type="javax.sql.XADataSource">
    <jdbcDriver libraryRef="DB2JCC4Lib"/>
    <properties.db2.jcc databaseName="ORDERDB" password="passw0rd" portNumber="{KUBERNETES_NODEPORT_VALUE}" serverName="10.0.0.1" user="admin"/>
</dataSource>
```
The correct **KUBERNETES_NODEPORT_VALUE** can be acquired via running `kubectl get services` command, using the value to the immediate right of the default 50000 port (somewhere in the range of 30000).

On a [terminal window](troubleshooting.md#open-the-terminal) where the [Kubernetes CLI has been configured on](troubleshooting.md#configure-the-kubernetes-cli), execute the `kubectl get services` command:

![Source migration 85](/static/imgs/toLiberty/Source85.png)

#### 6. Expand WAR and EAR files

Add the following lines to your server.xml file to configure your Liberty server to expand WAR and EAR files at startup so that you don't need to it manually:

```
<!-- Automatically expand WAR files and EAR files -->
<applicationManager autoExpand="true"/>
```

**IMPORTANT:** At this point, you should already have the server.xml with the needed configuration to successfully run the Customer Order Services application. However, **you still need to install the Liberty server features** described earlier in this section. In order to install them, you need to execute on a [terminal window](troubleshooting.md#open-the-terminal):

`~/PurpleCompute/wlp/bin/installUtility install <server_name>`

where **<server_name>** is the name you have given to your Liberty server [when you created it](#install-websphere-application-server-liberty-locally) at the beginning of this tutorial. If you have followed the instructions as they are, the Liberty server name should be **defaultServer**.

![Source migration 60](/static/imgs/toLiberty/Source60.png)

## Run the application

In order to locally run our application now that we seem to have the source code appropriately fixed/migrated to run on the WebSphere Liberty server and the proper WebSphere Liberty server configuration in place, we need to export the application as an EAR file. To do so, we right click on the CustomerOrderServicesApp project and select Export --> EAR file:

![Source migration 86](/static/imgs/toLiberty/Source86.png)

We are presented with a dialog to export our project as an EAR file. In this dialog, we must give our EAR project the appropriate name **CustomerOrderServicesApp** and the proper destination **/home/skytap/PurpleCompute/wlp/usr/shared/apps/CustomerOrderServicesApp.ear**. Finally, we optimize the application to run on WebSphere Application Server Liberty, select the Overwrite existing file option in case there was an existing application with the same name already and click Finish:

![Source migration 21](/static/imgs/toLiberty/Source21.png)

Once the EAR project has been exported as an EAR file into the shared applications folder for WebSphere Liberty (and the application itself as a result), go into the Servers tab at the bottom in eclipse, right click on WebSphere Application Server Liberty at localhost and click on start:

![Source migration 87](/static/imgs/toLiberty/Source87.png)

We should get moved to the Console tab in eclipse right away in order to see the WebSphere Liberty's output. We should then see something similar to:

![Source migration 22](/static/imgs/toLiberty/Source22.png)

where we can find the links for the two web applications deployed into WebSphere Liberty. One is a test project we will ignore for the time being. The other is the **Customer Order Services Web Application** and should be accessible at http://<SOME_IP>:9081/CustomerOrderServicesWeb/.

Use the IP the console in eclipse shows to access the application and open the application on firefox.

You will first be presented with a login dialog since we have application security for our application enabled which was done when configuring the WebSphere Liberty server in [this previous section](#4-application-security).

![Source migration 23](/static/imgs/toLiberty/Source23.png)

Introduce **rbarcia** as the username and **bl0wfish** as the password for the credentials. Once you have done that, we should see the Customer Order Services Application:

![Source migration 28](/static/imgs/toLiberty/Source28.png)

However, if we look into the Console tab for WebSphere Liberty in eclipse, we still see errors:

![Source migration 29](/static/imgs/toLiberty/Source29.png)

Looking carefully at them, we see there is a problem with the data type that is returned from the database and that this happens in the loadCustomer method in CustomerOrderServicesImpl.java. So if we look into that method we soon realise this is only trying to return an AbstractCustomer from the database:

![Source migration 30](/static/imgs/toLiberty/Source30.png)

Therefore, the problem must reside in the AbstractCustomer class. However, as the name suggests, this is an abstract class and thus it will not be instantiated. Instead, we need to look for the classes that extends such abstract class. These are BusinessCustomer and ResidentialCustomer. If we remember the SQL error we have in the WebSphere Liberty Console log, it is about a value 'Y' being returned as an integer. We then look at the Java classes and realise that some boolean attributes, which will get values of 'Y' and 'N', are being returned as Integer causing the SQL exception.

The reason for this is that the OpenJPA driver treats booleans differently based on its version. In this case, the OpenJPA driver version we are using in WebSphere Liberty does not convert 'Y' or 'N' database values into booleans automatically. As a result, we need to store them as Strings and check those Strings to return a boolean value:

1. Open BusinessCustomer.java and ResidentialCustomer.java that can be found on the CustomerOrderServices project:

![Source migration 88](/static/imgs/toLiberty/Source88.png)

2. Change the code on those java files to look like the following so that Boolean are stored as Integer and Integer are returned as Boolean:

![Source migration 31](/static/imgs/toLiberty/Source31.png)
![Source migration 32](/static/imgs/toLiberty/Source32.png)

Finally, save all the changes, export the project as EAR file to the WebSphere Liberty folder and start the Server up as we've already done before. You should now see the Customer Order Services web application with no errors at all in the Console tab for WebSphere Liberty in eclipse:

![Source migration 33](/static/imgs/toLiberty/Source33.png)

When completed, stop the Liberty server:

![Source migration 89](/static/imgs/toLiberty/Source89.png)

# Next step

Click [here](step2.md) to go to the next step, step 2.

Click [here](tutorial.md) to go to the tutorial initial page.
