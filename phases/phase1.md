# Phase 1 - Modernizing the Existing Application

WebSphere Application Server as a Service on IBM Bluemix allows existing IBM customers running WebSphere applications on-premise and new IBM customers to run these very same WebSphere applications and workloads on the IBM Cloud. However, this WebSphere Application Server as a Service on Bluemix supports only WebSphere Application Server version 8.5.5 onwards. As a result, prescriptive WebSphere guidance for modernizing WebSphere applications has been delivered and it is implemented through the following four steps:

1.  [Plan](#plan)
    * [Migration Strategy Tool](#migration-strategy-tool)
    * [Migration Discovery Tool](#migration-discovery-tool)
2.  [Assess](#assess)
    * [Evaluation](#evaluation)
    * [Inventory](#inventory)
    * [Analysis](#analysis)
3.  [Source Migration](#source-migration)
    * [Development Environment](#development-environment)
    * [Code Migration](#code-migration)
4.  [Config Migration](#config-migration)
    * [Traditional WebSphere Applications](#traditional-websphere-applications)

This readme aims to drive readers through the WebSphere guidance for modernizing WebSphere applications process by using our Customer Order Services reference application for the transition from [Customer Order Services for WAS 7.0](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/was70-dev) to [Customer Order Serivces for WAS 9.0](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/was90-dev).

## Plan

Moving your application to newer versions of WebSphere requires proper planning. The following resources helps you to plan successfully.

### Migration Strategy Tool

Before moving to a new version of Websphere, you need to know all the options available for your migration. This tool helps you in evaluating different options available for your WebSphere applications.

![Migration Strategy Tool-1](/phases/phase1_images/StrategyTool1.png?raw=true)
![Migration Strategy Tool-2](/phases/phase1_images/StrategyTool2.png?raw=true)

This tool can be accessed at http://whichwas.mybluemix.net/ 

### Migration Discovery Tool

This tool helps in migrating your applications to WebSphere by estimating the effort required. This tool estimates the size as well as the scope of migration. Planning and budget assumptions can be done. Based upon the answers to the questionnaire, historical data and effort hours, this tool generates a rough estimation for migration.

![Migration Discovery Tool-1](/phases/phase1_images/DiscoveryTool1.png?raw=true)

The tool walks you through a couple of Questions related to the installation, application and testing. Based upon your answers, it generates a summary of the information provided, rough order of magnitude estimations, scope, timeline etc.

![Migration Strategy Tool-2](/phases/phase1_images/DiscoveryTool2.png?raw=true)

This tool can be accessed at http://ibm.biz/MigrationDiscovery.

### WAS V9 TCA Calculator (Subscription and Support Cost Calculator)

This [tool](https://advantage.ibm.com/2015/04/02/was-vs-jboss-license-and-support-cost-calculator-updated/) helps you in evaluating licensing options for various available Java application servers like IBM WebSphere, Oracle WebLogic, Red Hat JBoss and Pivotal tc Server and helps you to make the right choice among them. 

The Total Cost of Acquisition (TCA) calculator is a quick tool that helps you to compare your existing S&S costs against the latest WAS V9 financial benefits.

![Licensing Options](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_images/TCO_licensing.png)

![TCA Calculator](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_images/TCO_cost_est.png)

### WAS V9 TCO Calculator (On-Premise and In Cloud Cost Calculator)

This [tool](https://roi-calculator.mybluemix.net/) helps you to view all the initial projection costs for creating new applications or to move the existing applications to bluemix. This information helps you to decide whether to keep your application on-premise or to move it to Bluemix. 

![roi-calculator](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_images/TCO_cost_calculator.png)

## Assess

Assessing your application helps you to understand all the potential issues during the migration process. During this phase, we will evaluate the programming models in our application and what WebSphere products support them. We will use the [WebSphere Migration Toolkit for Application Binaries](https://developer.ibm.com/wasdev/downloads/#asset/tools-Migration_Toolkit_for_Application_Binaries) and its [manual](https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wamt/ApplicationBinaryTP/MigrationToolkit_Application_Binaries_en_US.pdf) for this process.

### Evaluation

The Migration Toolkit for Application Binaries can generate an evaluation report that helps to evaluate the Java
technologies that are used by your application. The report gives a high-level review of the programming
models found in the application, the WebSphere products that support these programming models and the right-fit IBM platforms for your JEE application.

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath --evaluate`

_(I) binaryInputPath, which is an absolute or relative path to a JEE archive file or directory that contains JEE archive files_

![Evaluation Report](/phases/phase1_images/EvaluationReport.png?raw=true)

As we can see in the picture above, our Customer Order Services app fit a numerous IBM platforms such as the new Liberty profile either on-premises and on Bluemix as well as the traditional WebSphere server and deployment.

### Inventory

The Migration Toolkit for Application Binaries can generate an inventory report that contains a high-level inventory of the content and structure of each application and information about potential deployment problems. The report includes a dashboard that reports the number and types of archives found. The counts of Java Servlets, JSP files, JPA entities, EJB beans, and web services are reported per application as well as in an overall summary. For each archive, the Java EE module type and version are included. And for utility JAR files, the contained packages are reported up to and including the third sub package.

The report also includes a section for each application about potential deployment problems. The tool detects the following issues:

* Duplicate classes within the application
* Java EE or SE classes that are packaged with the application
* Open Source Software (OSS) classes that are packaged with the application
* WebSphere classes that are packaged with the application
* Unused archives that are packaged with the application
* Dependent classes that are not packaged with the application
* Shared libraries referencing application classes

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath --inventory`

_(I) binaryInputPath, which is an absolute or relative path to a JEE archive file or directory that contains JEE archive files_

[**Full Report**](http://htmlpreview.github.com/?https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_reports/CustomerOrderServicesApp.ear_InventoryReport.html)

This is the inventory summary for our application where we can see the information about the type and quantity of the different components contained in it. We should review the information presented in this report in order to make sure we are aware of all the pieces involved in the migration of our application.

![New inventory report](/phases/phase1_images/inventory_report/new/NewInventory1.png?raw=true)

If we scroll down, we get to the **Potential Deployment Problems** section which we should pay even more attention to as the earlier problems are detected and addressed if possible, the better.

![New inventory report 2](/phases/phase1_images/inventory_report/new/NewInventory2.png?raw=true)

We strongly recommend to click on the _Show details_ button on the _Problem Details_ subsection so that we can inspect each of the potential problems and determine whether this will be a problem or not.

### Analysis

The Migration Toolkit for Application Binaries can generate an analysis report that contains details about potential migration issues in your application. The tool helps you quickly and easily evaluate WebSphere Application Server traditional applications for their readiness to run on Liberty in both cloud and on-premises environments. The tool also supports migrating between versions of WebSphere traditional, starting with WebSphere Application Server Version 6.1.

The report gives details about which rules were flagged for your application binaries. For each flagged result, the report lists the affected file along with the match criteria, the method name if applicable, and the line number if available. Line numbers are only available for results that occur within a method body.

This analysis report should flag the same issues as the following Eclipse WebSphere Migration Toolkit plugin (Source Migration section). However, the analysis report comes with a show rule option where the user can read the rule explanation.

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath --analyze [OPTIONS]`

_(I) binaryInputPath, which is an absolute or relative path to a JEE archive file or directory that contains JEE archive files_

_(II) in our case, the [OPTIONS] are: --sourceAppServer=was70 --targetAppServer=was90 --sourceJava=ibm6 --targetJava=ibm8 --targetJavaEE=ee7 --*includePackages=org.pwte.example*_

[**Report**](http://htmlpreview.github.com/?https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_reports/CustomerOrderServicesApp.ear_AnalysisReport.html)

![Analyze report](/phases/phase1_images/analyze_report/Analyze2.png?raw=true)

Again, the Migration Toolkit for Application Binaries Analyze report is used for assessment. That is, its main goal is to *quantify the migration effort*. It should not be used for repackaging the application or make code changes. For doing so, we are going to use the Eclipse WebSphere Migration Toolkit plugin in the next section.

## Source Migration

### Development Environment

In order to carry out the migration of your source code from an old WebShere Application Server version to a newer one, we must set up a proper development environment for the task. In this case, we want to move away from IBM proprietary tools as much as possible. Hence, this is the stack of our development environment:

* [Eclipse Neon 3 for JEE developers](http://www.eclipse.org/downloads/packages/eclipse-ide-java-ee-developers/neon3)
* [IBM WebSphere Application Server V9.x Developer Tools for Eclipse](https://marketplace.eclipse.org/content/ibm-websphere-application-server-v9x-developer-tools#group-details)
* [IBM Installation Manager](http://www-01.ibm.com/support/docview.wss?uid=swg27025142) - (Recommended for the installation of the IBM WebSphere Application Server V9.0)
* IBM WebSphere Application Server V9.0

To install the IBM WebSphere Application Server V9.x Developer Tools for Eclipse:

1. Open eclipse.
2. Drag and drop the Install button into the eclipse main window.
3. Select all the options available.

![Source report 15](/phases/phase1_images/source_report/Source15.png?raw=true)

To install the IBM WebSphere Application Server V9.0:

1. Open the IBM Installation Manager.
2. Click on File --> Preferences...
3. Add the following repository: https://www.ibm.com/software/repositorymanager/V9WASILAN
4. Install the IBM WebSphere Application Server V9.0 with its latest fixpack and the IBM Java SDK Version 8. (There is no need to install Liberty for now).

![Source report 14](/phases/phase1_images/source_report/Source14.png?raw=true)

### Code Migration

The migration toolkit provides a rich set of tools that help you migrate applications from third-party application servers, between versions of WebSphere Application Server, to Liberty, and to cloud platforms such as Liberty for Java on IBM Bluemix, IBM WebSphere on Cloud and Docker.

First thing we will be prompted with, as soon as we import our WAS7.0 applications into eclipse, is the **Workspace Migration** dialog box.

![Source report 18](/phases/phase1_images/source_report/Source18.png?raw=true)

The reason for this is that eclipse has been configured to develop and deploy applications only for WAS 9.0 so it does not know anything about any WAS 7.0 server runtime in the system. **Click cancel** as this issue will be raised below by the **Software Analyzer**.

#### Software Analyzer Configuration

Click on **Run -> Analysis...** This will open the **Software Analyzer** which was installed as part of the IBM WebSphere Application Server V9.x Developer Tools for Eclipse in the previous [development environment](#development-environment) section.

![Source report 1](/phases/phase1_images/source_report/Source1.png?raw=true)

Now, **right-click** on _Sofwtare Analyzer_ and select **New**. Give a relevant and appropriate name to the new configuration and click on the **Rules** tab for this configuration. Select the **WebSphere Application Server Version Migration** option for the Rule Sets dropdown menu and click **Set...**

![Source report 19](/phases/phase1_images/source_report/Source19.png?raw=true)

The _Rule set configuration_ panel shoul be displayed. This panel must be configured so that the appropriate set of rules  based on our migration requirements are applied during the software analysis of our code.

![Source report 20](/phases/phase1_images/source_report/Source20.png?raw=true)

**NOTE:** It is important to note the six options that exist in the Java EE 7 technologies section. Traditional WAS V9 (tWAS V9) is a Java EE 7 runtime which by default runs newer levels of the CDI, EL, JAX-RS, JMS, JPA and Servlet specifications. These options allow you to state whether you intend to upgrade your application code to the latest specification during migration or not. In this case, we **do not** plan to upgrade the application from JPA 2.0 to JPA 2.1 (JPA 2.1 is now the default implementation for tWAS V9) or from JAX-RS 1.1 to JAX-RS 2.0(JAX-RS 2 is now the default for tWAS V9) since we are trying to **'lift & shift'** (again, making the least possible changes to get our app to work on a newer WAS version and IBM Platform like IBM Bluemix). Therefore, **leave those boxes unchecked**.

#### Running the Software Analyzer

After running the _Software Analyzer_ you should see a _Software Analyzer Results_ tab at the bottom. The number of results from the _Software Analyzer_ and the _Analyze report_ from the previous section can be different (due to scanning class files vs source files), but the same rules should be flagged. The only case where this might not be true is JPA. There were several very complex JPA rules that were not implemented in the binary scanner. But the binary scanner flag JPA migration issues, just not as extensively (since many of these more complex rules were to provide quick fixes which are not even available in the binary scanner).

The Software Analyzer rules are categorised, and so are the errors and warnings produced in its report, in four categories: Java Code Review, XML File Review, JSP Code Review and File Review. We must go through each of these tabs/categories and review the errors and warnings as code/configuration changes might be needed.

![Source report 21](/phases/phase1_images/source_report/Source21.png?raw=true)

If we inspect the four categories, we will find out that the **JSP Code Review** and **XML File review** come out clean. As a result, we need to take care of the other two categories only. We will start off with the **File Review** analysis tab. As you can see in the image below, one warning that will always appear when you migrate your apps to a newer WebSphere Application Server version is the need to configure the appropriate target runtime for your applications. This is the first and foremost step:

![Source report 2](/phases/phase1_images/source_report/Source2.png?raw=true)

Along with the warning and errors reported after analyzing the code, the WebSphere Application Migration Toolkit comes also with information about the rule that flagged the error/warning as well as possible solutions for it. In order to see this info and help, click on **Help -> Show Contextual Help**. This will open the help portlet in eclipse.

![Source report 16](/phases/phase1_images/source_report/Source16.png?raw=true)

If you scroll down to the bottom and press on the "detailed help" button it will show you additional ideas on how to resolve that problem.

![Source report 17](/phases/phase1_images/source_report/Source16.png?raw=true)

As suggested by the help information coming along with the WebSphere Application Migration Toolkit, we select _WebSphere Application Server traditional V9.0_ as the **targeted runtime** for each of the projects.

![Source report 22](/phases/phase1_images/source_report/Source22.png?raw=true)

The next warning on this same **File Review** section is about the _Context and Dependency Injection_

![Source report 23](/phases/phase1_images/source_report/Source23.png?raw=true)

And this is what the detailed help tells us:

![Source report 24](/phases/phase1_images/source_report/Source24.png?raw=true)

We can see that the WebSphere Application Migration Toolkit is warning us of a CDI scan behaviour change which might result on a degraded startup performance. Ideally, we should address this issue. However, since we are **lifting and shifting** the app, we are only changing those pieces of code/configuration that will prevent our app to run on a newer WebSphere Application Server version and different IBM platform. Therefore, we can just bear this warning in mind for a future refactoring/enhancement of our apps.

Moving on to the **Java Code Review** category tab, these are the aspects the WebSphere Application Migration Toolkit warns us about:

![Source report 25](/phases/phase1_images/source_report/Source25.png?raw=true)

The first warning implies the JAX-RS implementation level we are using in our apps:

![Source report 26](/phases/phase1_images/source_report/Source26.png?raw=true)

If we open the detailed help for it we can read the following:

![Source report 27](/phases/phase1_images/source_report/Source27.png?raw=true)

The WebSphere Application Migration Toolkit is warning us about our apps using an older JAX-RS implementation level than what the WebSphere Application Server version we are migrating them to uses. However, it also says that the newer WAS version we are migrating our apps to supports older JAX-RS implementation levels as well if it is accordingly configured. Again, since we are trying to modify/change our applications the least possible due to the **'lift & shift'** pattern we are applying, we will configure WAS to use the JAX-RS implementation level our applications were built on. The links that come with the detailed help get us to:

![Source report 28](/phases/phase1_images/source_report/Source28.png?raw=true)

and

![Source report 29](/phases/phase1_images/source_report/Source29.png?raw=true)

The second aspect the WebSphere Application Migration Toolkit brings up is about the JPA version our apps are using:

![Source report 30](/phases/phase1_images/source_report/Source30.png?raw=true)

and this is what the detailed help says:

![Source report 31](/phases/phase1_images/source_report/Source31.png?raw=true)

That is, our apps were built based on an older JPA version than what the WAS version we are migrating our apps to uses as the default JPA version. Once again, older versions of JPA are supported by the newer WAS vesion as long as it is accordingly configured. See [Configuring the WSJPA persistence provider](https://www.ibm.com/support/knowledgecenter/en/SSAW57_9.0.0/com.ibm.websphere.nd.multiplatform.doc/ae/tejb_jpadefaultpp.html):

![Source report 32](/phases/phase1_images/source_report/Source32.png?raw=true)

The thrid aspect the WebSphere Application Migration Toolkit flags is again about the Context and Dependency Injection:

![Source report 33](/phases/phase1_images/source_report/Source33.png?raw=true)

for which we get the following detailed information:

![Source report 34](/phases/phase1_images/source_report/Source34.png?raw=true)

After reading the detialed info for the CDI warning we realise is the exact same issue we have already addressed in the **File Review** section so we can skip it as long as the appropriate actions were already taken.

Last aspect in this **Java Code Review** section has to do with a change in the JPA cascade strategy:

![Source report 35](/phases/phase1_images/source_report/Source35.png?raw=true)

and its detailed information says the following:

![Source report 36](/phases/phase1_images/source_report/Source36.png?raw=true)

As we can read in the detailed info above, the change in the JPA cascade strategy is not expected to affect most applications. Also, this new cascade strategy can be mitigated by simply reverting to the previous behaviour by setting the _openjpa.Compatibility_ peroperty in the persistence.xml file. Hence, we just need to bear this potential issue in mind during the testing phase of our apps on the new WAS version and IBM platform and take the appropriate action if they happen to be affected.

#### Summary

In this section, we have seen how to configure and run the Software Analyzer the WebSphere Application Migration Toolkit comes with which helps you out identifying potential issues when migrating your applications to a newer WebSphere Application Server version and/or to a different IBM Platform. It is then down to developers to review all these potential issues and make the appropriate changes in advance. In our case, we have seen that no code changes are needed. Instead, a simply set up of the targeted runtime for our applications and an appropriate version configuration for the Java Technologies our apps use (such as JAX-RS and JPA) in WebSphere Application Server administrative console should suffice to get our applications to run on WebSphere Application Server 9.0.

Nonetheless, our migrated applications must go through a thorough test phase in order to make sure their behaviour has not changed at all and, if so, developers must work on appropriate code fixes.

Finally, it is recommended to consider upgrading the Java Technologies your applications use to the newest implementation levels and drivers not only to get the best support for them both from IBM and the community in general but also to get the best performance out of the newer WebSphere Application Server you are now running your apps on.

## Config Migration

Migration of configuration should be done before deploying the application on the latest versions of WebSphere. The configurations can be migrated from traditional WebSphere application servers or from third party application servers too. 

Below are the two tools available for Configuration migration.

1. [Migration Wizard](https://www.ibm.com/support/knowledgecenter/en/SSAW57_9.0.0/com.ibm.websphere.migration.nd.doc/ae/tmig_profiles_gui.html)
2. [Eclipse based configuration migration tool]( https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Configuration_Migration_Tool)

### Traditional WebSphere (Profile Migration)

Full profile migration can be done using WASPreUpgrade and WASPostUpgrade commands as well using the graphical user interface, the Configuration Migration Tool.

#### Cloning the profile using the command line

WASPreUpgarde and WASPostUpgrade commands can be used to perform the migration using the command line.

**WASPreUpgrade** - This allows you to backup all the configuration data from the source profile into a migration backup directory.

**WASPostUpgrade** - This allows you to merge all the source data into the new target profile.

`./WASPreUpgrade.sh /home/vagrant/IBM/WASMigration /home/vagrant/IBM/WebSphere/AppServer/ -oldProfile AppSrv01 -username admin -password password`

![WASPreUpgrade](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_images/WASConfig/WASPreUpgarde.png)

`./manageprofiles.sh -create -profileName AppSrv01 -profilePath /home/vagrant/IBM/WebSphere/AppServer_2/profiles/AppSrv01 -templatePath /home/vagrant/IBM/WebSphere/AppServer_2/profileTemplates/default -defaultPorts -enableAdminSecurity true -adminUserName admin -adminPassword password`

![WASProfileManagement](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_images/WASConfig/WASProgileMgt.png)

`./WASPostUpgrade.sh /home/vagrant/IBM/WebSphere/WSMigration -username admin -password password -oldProfile AppSrv01 -profileName AppSrv01 -setPorts generateNew -resolvePortConflicts incrementCurrent -includeApps false -clone true`

![WASPostUpgrade](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_images/WASConfig/WASPostUpgrade.png)

#### Cloning the profile using the Configuration MigrationTool

Version to version configuration migration support is incorporated within the WebSphere Application Server itself. There is an inbuilt Configuration Migration Tool within the server and this tool walks you through the migration wizard which helps you in the migration process.

IBM WebSphere Application Server V9.0 contains a WebSphere Customization toolbox.

![WebSphere Customization ToolBox1](/phases/phase1_images/TWAS1.png?raw=true)

Create a migration using the New option available. This guide you through several steps and finally returns the migration summary. Verify the summary and proceed with the migration.

![WebSphere Customization ToolBox2](/phases/phase1_images/TWAS2.png?raw=true)

Once the migration is completed, it returns you the migration results. Check them out and complete the migration using Finish option.

![WebSphere Customization ToolBox3](/phases/phase1_images/TWAS3.png?raw=true)

![WebSphere Customization ToolBox4](/phases/phase1_images/TWAS4.png?raw=true)

This procedure can be followed only if the migration is between different versions of WebSphere.

The above tools are best suited for the scenarios where the migration of cells is similar. They are great where the target cell has the same number of node agents, the same number of clusters, the same number of cluster members, etc. 

These tools do not work well if there is some consolidation or other re-architecture of their topologies. When there is refactoring of the topologies then you can make use of Eclipse WebSphere Configuration Migration tool(WCMT).

### Traditional WebSphere (Resource Migration)

[Eclipse-based WebSphere Configuration Migration tool](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Configuration_Migration_Tool) can be used to migrate the configuration from different types of servers to WebSphere application server. This tool supports Traditional WebSphere Applications as well as the Third-party server applications.

Once this tool gets installed in your IDE, you can access it using the option Migration Tools.

![Eclipse Plugin1](/phases/phase1_images/EclipsePlugin1.png?raw=true)

Choose your environment and proceed with the migration.

![Eclipse Plugin2](/phases/phase1_images/EclipsePlugin2.png?raw=true)

`./wsadmin.sh –lang jython –c “AdminTask.extractConfigProperties(‘[-propertiesFileName my.props]’)”`

After executing this command, my.props file will be generated. The properties file for this sample application can be accessed here [my.props](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_assets/my.props) 

![Eclipse Plugin3](/phases/phase1_images/EclipsePlugin3.png?raw=true)

![Eclipse Plugin4](/phases/phase1_images/EclipsePlugin4.png?raw=true)

![Eclipse Plugin5](/phases/phase1_images/EclipsePlugin5.png?raw=true)

At this step, save your configuration file and Finish the migration. By the end, you will have jython script saved as the configuration file. 

The configuration file generated for this sample application can be accessed here [migConfig.py](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_assets/migConfig.py) 

Finally stop the source server.

Now, start your target server. 

Go to the **<WAS_PROFILE_DIR>/bin**, and use the following command.

`<Profile Home>/bin/wsadmin.(bat/sh) –lang jython –f <Location of Jython script>`

![Eclipse Plugin6](/phases/phase1_images/EclipsePlugin6.png?raw=true)

Once the script gets executed successfully, the migration is complete.

![Eclipse Plugin7](/phases/phase1_images/EclipsePlugin7.png?raw=true)

You can verify the migration by opening your admin console and then check if all the resources are correct.


## Other useful links

* [Migrating to WAS 8.5.5](http://www.redbooks.ibm.com/abstracts/sg248048.html) - (Redbook)
* [Migration](https://developer.ibm.com/wasdev/docs/migration/) - (developerWorks Blog)
* [IBM WebSphere Application Server Migration Toolkit](https://www.ibm.com/developerworks/library/mw-1701-was-migration/index.html) - (developerWorks Blog)
* [WebSphere Migration Knowledge Collection](http://www-01.ibm.com/support/docview.wss?uid=swg27008728)
