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

Assessing your application helps you to understand all the potential issues during the migration process.

#### Migration Toolkit for binaries

This toolkit generates a set of reports which helps us in rapid deployment. This toolkit can be accessed at https://developer.ibm.com/wasdev/downloads/#asset/tools-Migration_Toolkit_for_Application_Binaries.

##### Evaluation

This report helps you to rapidly assess the application for latest versions of WebSphere or Liberty. It helps in recognizing various Java programming models in the application and suggests the right fit IBM WebSphere Version.

To get the report, run `java -jar binaryAppScanner.jar binaryInputPath`

![Evaluation Report](/phases/phase1_images/EvaluationReport.png?raw=true)

##### Inventory

Details to be added

##### Analysis

Details to be added

### Source Migration

Details to be added later

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

![Eclipse Plugin3](/phases/phase1_images/EclipsePlugin3.png?raw=true)

![Eclipse Plugin4](/phases/phase1_images/EclipsePlugin4.png?raw=true)

![Eclipse Plugin5](/phases/phase1_images/EclipsePlugin5.png?raw=true)

At this step, save your configuration file and Finish the migration. By the end, you will have jython script saved as the configuration file. Finally stop the source server.

Now, start your target server. 

Go to the **<WAS_PROFILE_DIR>/bin**, and use the following command.

`<Profile Home>/bin/wsadmin.(bat/sh) –lang jython –f <Location of Jython script>`

![Eclipse Plugin6](/phases/phase1_images/EclipsePlugin6.png?raw=true)

Once the script gets executed successfully, the migration is complete.

![Eclipse Plugin7](/phases/phase1_images/EclipsePlugin7.png?raw=true)

You can verify the migration by opening your admin console and then check if all the resources are correct.














