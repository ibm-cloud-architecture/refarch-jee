# Phase 1 - Modernizing the Existing Application

WebSphere Application Server as a Service on IBM Bluemix allows existing IBM customers running WebSphere applications on-premise and new IBM customers to run these very same WebSphere applications and workloads on the IBM Cloud. However, this WebSphere Application Server as a Service on Bluemix supports only WebSphere Application Server version 8.5.5 onwards. As a result, prescriptive WebSphere guidance for modernizing WebSphere applications has been delivered and it is implemented through the following four steps:

1.  [Plan](#plan)
2.  [Assess](#assess)
3.  [Source Migration](#source-migration)
4.  [Config Migration](#config-migration)

This readme aims to drive readers through the WebSphere guidance for modernizing WebSphere applications process by using our Customer Order Services reference application for the transition from [Customer Order Services for WAS 7.0](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/rad96-was70) to [Customer Order Serivces for WAS 9.0](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/eclipse-was90).

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

## Assess

Assessing your application helps you to understand all the potential issues during the migration process. During this phase, we will evaluate the programming models in our application and what WebSphere products support them. We will use the [WebSphere Migration Toolkit for Application Binaries](https://developer.ibm.com/wasdev/downloads/#asset/tools-Migration_Toolkit_for_Application_Binaries) and its [manual](https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/downloads/wamt/ApplicationBinaryTP/MigrationToolkit_Application_Binaries_en_US.pdf) for this process.

### Evaluation

The Migration Toolkit for Application Binaries can generate an evaluation report that helps to evaluate the Java
technologies that are used by your application. The report gives a high-level review of the programming
models found in the application, the WebSphere products that support these programming models and the right-fit IBM platforms for your J2EE application.

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath --evaluate`

_(I) binaryInputPath, which is an absolute or relative path to a J2EE archive file or directory that contains J2EE archive files_

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

_(I) binaryInputPath, which is an absolute or relative path to a J2EE archive file or directory that contains J2EE archive files_

[**Initial Report**](http://htmlpreview.github.com/?https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_reports/CustomerOrderServicesApp.ear_InventoryReport_Initial.html)

As we can see in the report, there are several concerning facts such as duplicate or unused libraries we should pay attention to and which we higly recommend fixing before migrating your application to a newer WebSphere Application Server version and/or different IBM platform. Hence, we will go through the process of fixing these potential future problems by making use of this inventory report.

Firstly, we see a summary section which might already raise concerns in us such as the high amount of utility JARs found in the J2EE archive of our Customer Order Services application. As we scroll down, we rapidly get to the _Inventory Details by Application_ where we find out that there are several libraries being marked as duplicate or unused which we certainly need to look at:

![Inventory report](/phases/phase1_images/inventory_report/Inventory1.png?raw=true)

After removing the unused libraries and verifying that this does not introduce any other problem/error in the code, we look at the ear structure, its ejb, web and test projects. We realise that there are several libraries being used by multiple projects but yet included in each of them as opposed to packaging them at the ear level as a shared library among all ear project components. After repackaging libraries at the ear level, this is how the inventory report looks like:

![Inventory report 2](/phases/phase1_images/inventory_report/Inventory2.png?raw=true)

We see now that both web projects and the ejb project look fine library wise. However, the report indicates that there are still several duplicate libraries. Looking in detail at what packages those duplicate libraries come with, we realise that, in effect, several libraries packages are included by others (normally broader and heavier Java libraries. For instance, the _jackson-all_ library includes all packages the other three lighter and more specific jackson libraries come with). We then remove remaining duplicate libraries and run the report again:

![Inventory report 3](/phases/phase1_images/inventory_report/Inventory3.png?raw=true)

Now, we do not see any more duplicate libraries. However, we still see warnings due to libraries we are packaging our application with which either include Open Source Software, Java EE or SE classes or WebSphere system classes. Reading at the rules explanation, we are suggested to review what libraries our WebSphere Application Server plus Java Runtime Environment come with since they might already be included:

![Inventory report 4](/phases/phase1_images/inventory_report/Inventory4.png?raw=true)

It is important to use, as much as possible, the libraries that already come with your middleware stack so that we avoid class loading issues. Hence, we look at the WebSphere Application Server and Java Runtime Environment libraries in our environment and we effectively verify that we were including libraries again that were already packaged with our WebSphere Application Server version:

![Inventory report 5](/phases/phase1_images/inventory_report/Inventory5.png?raw=true)

Again, we remove these libraries and run the report. This time, the report comes finally clean except from some warnings regarding missing dependencies on some projects/libraries.

![Inventory report 6](/phases/phase1_images/inventory_report/Inventory6.png?raw=true)
![Inventory report 7](/phases/phase1_images/inventory_report/Inventory7.png?raw=true)

Looking at those, we find out that libraries reporting missing dependencies for the ejb, test and web project are not, in fact, missing so then we should be good there. Classes reported are missing in the _DBUnit.jar_ library are never used so we are good there too.

Finally, we have repackaged and refactor our application structure to a situation were we do not have duplicate or unused libraries and the libraries we want/need to include are packaged in the proper location. At this point, we are now ready to start the migration to the newer WebSphere Application Server version or IBM Platform.

[**Final Report**](http://htmlpreview.github.com/?https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_reports/CustomerOrderServicesApp.ear_InventoryReport_Final.html)

### Analysis

The Migration Toolkit for Application Binaries can generate an analysis report that contains details about potential migration issues in your application. The tool helps you quickly and easily evaluate WebSphere Application Server traditional applications for their readiness to run on Liberty in both cloud and on-premises environments. The tool also supports migrating between versions of WebSphere traditional, starting with WebSphere Application Server Version 6.1.

The report gives details about which rules were flagged for your application binaries. For each flagged result, the report lists the affected file along with the match criteria, the method name if applicable, and the line number if available. Line numbers are only available for results that occur within a method body.

This analysis report should flag the same issues as the following Eclipse WebSphere Migration Toolkit plugin (Source Migration section). However, the analysis report comes with a show rule option where the user can read the rule explanation.

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath --analyze [OPTIONS]`

_(I) binaryInputPath, which is an absolute or relative path to a J2EE archive file or directory that contains J2EE archive files_

_(II) in our case, the [OPTIONS] are: --sourceAppServer=was70 --targetAppServer=was90 --sourceJava=ibm6 --targetJava=ibm8
--targetJavaEE=ee7_

[**Report**](http://htmlpreview.github.com/?https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_reports/CustomerOrderServicesApp.ear_AnalysisReport.html)

In this first phase, the goal is to 'lift & shift' our WebSphere applications with the minimum effort/change. As a result, we will only look at the errors reported which in our case are:

![Analyze report](/phases/phase1_images/analyze_report/Analyze1.png?raw=true)

We are going to use the Eclipse WebSphere Migration Toolkit plugin to look at and fix the errors above since changing code, libraries, etc is easier in an IDE.

## Source Migration

The migration toolkit provides a rich set of tools that help you migrate applications from third-party application servers, between versions of WebSphere Application Server, to Liberty, and to cloud platforms such as Liberty for Java on IBM Bluemix, IBM WebSphere on Cloud and Docker.

The eclipse-based WebSphere Application Server Migration Toolkit can be downloaded [here](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Application_Server_Migration_Toolkit).

Once it has been installed, create a new _Software Analyzer Configuration_ with your migration specifications. In our case, we set the configuration to a WAS 7.0 to WAS 9.0 migration taking JPA and JAX-RS into account.

![Source report 1](/phases/phase1_images/source_report/Source1.png?raw=true)

After running the _Software Analyzer_ you should see a _Software Analyzer Results_ tab at the bottom. In here, we should have the exact same errors and warnings as the _Analyzer report_ in the previous section. The Software Analyzer rules are categorised and so are the errors and warnings produced in its report. As you can see in the image, one warning that will always appear in when you migrate your apps to a newer WebSphere Application Server version is the need to configure the appropriate target runtime for your applications. This is the first and foremost step:

![Source report 2](/phases/phase1_images/source_report/Source2.png?raw=true)

In addition to this, you should also remove old WebSphere Application Server specific libraries. In our case, we should remove the reference to the _IBM WebSphere Application Server traditional V7.0 JAX-RS Library_ which was installed as a Feature pack:

![Source report 3](/phases/phase1_images/source_report/Source3.png?raw=true)

Setting the appropriate target runtime and removing previous WebSphere Application Server version specific libraries might introduce problems in the code:

![Source report 4](/phases/phase1_images/source_report/Source4.png?raw=true)

At this point, we must look at the other errors reported by the WebSphere Application Server Migration Toolkit since they often are because of previous WebSphere Application Server version specific libraries not available (initially) in the new WebSphere Application Server version. In our case, we see that the problems in the code are due to the _org.apache.wink_ library missing which is something the Analyze report and the Migration Toolkit also flag:

![Source report 5](/phases/phase1_images/source_report/Source5.png?raw=true)

As we said previously, there are pros and cons of using the Migration Toolkit for Application Binaries Analyze report over the eclipse-based WebSphere Application Server Migration Toolkit plugin to migrate your code to a newer WebSphere Application Server version and viceversa. Therefore, we suggest to use both in conjunction. The advantage of using the eclipse-based WebSphere Application Server Migration Toolkit plugin is, in fact, because it is used in an IDE so you can take advantage of using IDE's suggestions, tools and help:

![Source report 6](/phases/phase1_images/source_report/Source6.png?raw=true)

However, the Migration Toolkit for Application Binaries Analyze report has the advantage of comming with an explanation of the rule being applied so that the user can better understand the reason why a warning or error has been reported:

![Source report 7](/phases/phase1_images/source_report/Source7.png?raw=true)

We have to be careful and thoroughly review each of the errors and warning either of the toolkits report since there might be some that actually do not apply due to the possibility of having WebSphere Application Server fixpacks or feature packs installed. For instance, in our case, both toolkits report an error because we are using the _org.codehaus.jackson_ packages that are exposed as a third-party API in JAX-RS 1.1 but are not part of the new JAX-RS 2.0 version WebSphere Application Server V9.0 comes initially with. However, we find out that our WebSphere Application Server V9.0 comes with such packages possibly because of later fix packs installed as we are really using the 9.0.0.3 version of WebSphere Application Server:

![Source report 8](/phases/phase1_images/source_report/Source8.png?raw=true)

The last error reported is about the JPA version used in our code. In the WebSphere Application Server V7.0 we are migrating our code from, we were using its Feature Pack for OSGI and JPA which comes with the JPA 2.0 version. In contrast, the WebSphere Application Server V9.0 which we want to migrate our code to uses JPA 2.1 where the provider has changed from being _openJPA_ to _eclipseLink_. As a result, methods, annotations, etc are no longer valid or its behaviour has changed:

![Source report 9](/phases/phase1_images/source_report/Source9.png?raw=true)
![Source report 10](/phases/phase1_images/source_report/Source10.png?raw=true)


However, new WebSphere Application Server versions should have backwards compatibility in most of the JavaEE technologies and turns out that JPA is one of those. Remember that our goal is to migrate our existing code/apps running on WebSphere Application Server V7.0 to run on a newer WebSphere Application Server version supported by WASaaS on Bluemix but with the minimum possible changes which is what the 'lift & shift' pattern consist of (modernization of your application, Java technologies wise, might be carried out on a later stage). Because of this, we can take advantage of the backwards compatibility on the JPA version and providers the new WebSphere Application Server V9.0 comes with and configure it to use JPA 2.0 so that we do not need to change anything in our app at all:

![Source report 11](/phases/phase1_images/source_report/Source11.png?raw=true)

We have finally review all the errors reported by either the Migration Toolkit for Application Binaries or the eclipse-based WebSphere Application Server Migration Toolkit plugin. Now, the application and code should be deeply and carfully tested in order to make sure that the migration to a newer WebSphere Application Server version has not changed its behaviour at all. Hence, the more unit test, integration test and test in general your application and code had already implemented and come with for the old WebSphere Application Server version, the better, easier and trustworthy will this migration verification and validation process be.

## Config Migration

Migration of configuration should be done before deploying the application on the latest versions of WebSphere. The configurations can be migrated from traditional WebSphere application servers or from third party application servers too. 

Below are the two tools available for Configuration migration.

1. WebSphere Customization Toolbox
2. [Eclipse-based application migration tool](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Application_Server_Migration_Toolkit)

### Traditional WebSphere Applications

Version to version configuration migration support is incorporated within the WebSphere Application Server itself. There is an inbuilt Configuration Migration Tool within the server and this tool provides walks you through the migration wizard which helps you in the migration process.

IBM WebSphere Application Server V9.0 contains a WebSphere Customization toolbox.

![WebSphere Customization ToolBox1](/phases/phase1_images/TWAS1.png?raw=true)

Create a migration using the New option available. This guide you through several steps and finally returns the migration summary. Verify the summary and proceed with the migration.

![WebSphere Customization ToolBox2](/phases/phase1_images/TWAS2.png?raw=true)

Once the migration is completed, it returns you the migration results. Check them out and complete the migration using Finish option.

![WebSphere Customization ToolBox3](/phases/phase1_images/TWAS3.png?raw=true)

![WebSphere Customization ToolBox4](/phases/phase1_images/TWAS4.png?raw=true)

This procedure can be followed only if the migration is between different versions of WebSphere.

 Third Party Application Servers / Traditional WebSphere Application Server

[Eclipse-based application migration tool](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Application_Server_Migration_Toolkit) can be used to migrate the configuration from different types of servers to WebSphere application server. This tool supports Traditional WebSphere Applications as well as the Third-party server applications.

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
