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

Details to be added later
