# Enterprise Application Modernization through Java EE on Cloud

## Phase 1 - Modernizing the Existing Application

Prescriptive WebSphere guidance provides a process for modernizing WebSphere applications through four steps:

1.  Plan
2.  Assess
3.  Source Migration
4.  Config Migration

That process is captured here for the transition from [Customer Order Services for WAS 7.0](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/rad96-was70) to [Customer Order Serivces for WAS 8.5.5](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/rad96-was855).

### Plan

Moving your application to newer versions of WebSphere requires proper planning. The following resources helps you to plan successfully.

#### Migration Strategy Tool

Before moving to a new version of Websphere, you need to know all the options available for your migration. This tool helps you in evaluating different options available for your WebSphere applications.

![Migration Strategy Tool-1](/phases/phase1_images/StrategyTool1.png?raw=true)
![Migration Strategy Tool-2](/phases/phase1_images/StrategyTool2.png?raw=true)

This tool can be accessed at http://whichwas.mybluemix.net/ 

#### Migration Discovery Tool

This tool helps in migrating your applications to WebSphere by estimating the effort required. This estimates the size as well as the scope of migration. Planning and budget assumptions can be done. Based upon the answers to the questionnaire, historical data and effort hours, this tool generates a rough estimation for migration.

![Migration Discovery Tool-1](/phases/phase1_images/DiscoveryTool1.png?raw=true)

This walks you through a couple of Questions related to the installation, application and testing. Based upon your answers, it generates a summary of the information provided, rough order of magnitude estimations, scope, timeline etc.

![Migration Strategy Tool-2](/phases/phase1_images/DiscoveryTool2.png?raw=true)

This tool can be accessed at http://ibm.biz/MigrationDiscovery.

### Assess

Assessing your application helps you to understand all the potential issues during the migration process. During this phase, we will evaluate the programming models in our application and what WebSphere products support them. We will use the [WebSphere Migration Toolkit for Application Binaries](https://developer.ibm.com/wasdev/downloads/#asset/tools-Migration_Toolkit_for_Application_Binaries).

#### Evaluation

The Migration Toolkit for Application Binaries can generate an evaluation report that helps to evaluate the Java
technologies that are used by your application. The report gives a high-level review of the programming
models found in the application, the WebSphere products that support these programming models and the right-fit IBM platforms for your J2EE application.

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath --evaluate`

_(I) binaryInputPath, which is an absolute or relative path to a J2EE archive file or directory that contains J2EE archive files_

![Evaluation Report](/phases/phase1_images/EvaluationReport.png?raw=true)

As we can see in the picture above, our Customer Order Services app fit a numerous IBM platforms such as the new Liberty profile either on-premises and on Bluemix as well as the traditional WebSphere server and deployment.

#### Inventory

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

-- EVALUATION REPORT --

As we can see in the report, there are several concerning facts such as duplicate or unused libraries we should pay attention to and which we higly recommend fixing before migrating your application to a newer WebSphere version and/or IBM platform. Hence, we will go through the process of fixing these potential future problems by making use of this inventory report.

Firstly, we see a summary section which might already raise concerns in us such as the high amount of utility JARs found in the J2EE archive of our Customer Order Service application. As we scroll down, we rapidly get to the _Inventory Details by Application_ where we find out that there are several libraries being marked as duplicate or unused we certainly need to look at:

-- EVALUATION REPORT INITIAL --







#### Analysis

The Migration Toolkit for Application Binaries can generate an analysis report that contains details about potential migration issues in your application. The tool helps you quickly and easily evaluate WebSphere Application Server traditional applications for their readiness to run on Liberty in both cloud and on-premises environments. The tool also supports migrating between versions of WebSphere traditional, starting with WebSphere Application Server Version 6.1.

The report gives details about which rules were flagged for your application binaries. For each flagged result, the report lists the affected file along with the match criteria, the method name if applicable, and the line number if available. Line numbers are only available for results that occur within a method body.

This analysis report should flag the same issues as the following Eclipse WebSphere Migration Toolkit plugin (Source Migration section). However, the analysis report comes with a show rule option where the user can read the rule explanation.

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath --analyze [OPTIONS]`

_(I) binaryInputPath, which is an absolute or relative path to a J2EE archive file or directory that contains J2EE archive files_

_(II) in our case, the [OPTIONS] are: --sourceAppServer=was70 --targetAppServer=was90 --sourceJava=ibm6 --targetJava=ibm8
--targetJavaEE=ee7_

[**Report**](/phase1_reports/CustomerOrderServicesApp.ear_AnalysisReport.html)

In this first phase, the goal is to 'lift & shift' our WebSphere applications with the minimum effort/change. As a result, we will only look at the errors reported which in our case are:

![Analyze report](/phases/phase1_images/analyze_report/Analyze1.png?raw=true)

We are going to use the Eclipse WebSphere Migration Toolkit plugin to look at and fix the errors above since changing code, libraries, etc is easier in an IDE.

### Source Migration

The migration toolkit provides a rich set of tools that help you migrate applications from third-party application servers, between versions of WebSphere Application Server, to Liberty, and to cloud platforms such as Liberty for Java on IBM Bluemix, IBM WebSphere on Cloud and Docker.

The eclipse-based WebSphere Application Server Migration Toolkit can be downloaded [here](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Application_Server_Migration_Toolkit).

Once it has been installed, create a new _Software Analyzer Configuration_ with your migration specifications. In our case, we set the configuration to a WAS 7.0 to WAS 9.0 migration taking JPA and JAX-RS into account.

![Source report 1](/phases/phase1_images/source_report/Source1.png?raw=true)

After running the _Software Analyzer_ you should see a _Software Analyzer Results_ tab at the bottom. In here, we should have the exact same errors and warnings as the _Analyzer report_ in the previous section. As you can see in the image, one warning that will always appear in when you migrate your apps to a newer WebSphere Application Server version is the need to configure the appropriate target runtime for your applications. This is the first and foremost step:

![Source report 2](/phases/phase1_images/source_report/Source2.png?raw=true)

In addition to this, you should also remove old WebSphere Application Server specific libraries. In our case, we should remove the reference to the _IBM WebSphere Application Server traditional V7.0 JAX-RS Library_ which was installed as a Feature pack:

![Source report 3](/phases/phase1_images/source_report/Source3.png?raw=true)

Setting the appropriate target runtime and removing previous WebSphere Application Server version specific libraries might introduce problems in the code:

![Source report 4](/phases/phase1_images/source_report/Source4.png?raw=true)

At this point, we must look at the other errors reported by the WebSphere Application Server Migration Toolkit since they often are because of previous WebSphere Application Server version specific libraries not available (initially) in the new WebSphere Application Server version. In our case, we see that the problems in the code are due to the _org.apache.wink_ library missing which is something the Analyze report and the Migration Toolkit report too:




### Config Migration

Migration of configuration should be done before deploying the application on the latest versions of WebSphere. The configurations can be migrated from traditional WebSphere application servers or from third party application servers too. 

Below are the two tools available for Configuration migration.

1. WebSphere Customization Toolbox
2. [Eclipse-based application migration tool](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Application_Server_Migration_Toolkit)

#### Traditional WebSphere Applications

Version to version configuration migration support is incorporated within the WebSphere Application Server itself. There is an inbuilt Configuration Migration Tool within the server and this tool provides walks you through the migration wizard which helps you in the migration process.

IBM WebSphere Application Server V9.0 contains a WebSphere Customization toolbox.

![WebSphere Customization ToolBox1](/phases/phase1_images/TWAS1.png?raw=true)

Create a migration using the New option available. This guide you through several steps and finally returns the migration summary. Verify the summary and proceed with the migration.

![WebSphere Customization ToolBox2](/phases/phase1_images/TWAS2.png?raw=true)

Once the migration is completed, it returns you the migration results. Check them out and complete the migration using Finish option.

![WebSphere Customization ToolBox3](/phases/phase1_images/TWAS3.png?raw=true)

![WebSphere Customization ToolBox4](/phases/phase1_images/TWAS4.png?raw=true)

This procedure can be followed only if the migration is between different versions of WebSphere.

#### Third Party Application Servers / Traditional WebSphere Application Server

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














