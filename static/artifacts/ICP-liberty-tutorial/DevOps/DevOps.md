# Build and deploy using Jenkins
In this exercise we will go through the steps of creating a pipeline in Jenkins running on ICp. 
The pipeline will compile the code from source, build and push docker image and deploy the application on Kubernetes.

Jenkins will be installed from the ICp Application Catalog, and only minimal configuration will be required to be able to build and deploy the CustomerOrderServices application.

The pipeline steps will be provided to Jenkins from a Jenkinsfile in github each build, meaning that also the pipeline configuration is under version control.


# Setup

### Install and access Jenkins
1. Install Jenkins from app center
1. Open Jenkins UI by clicking the **access http** link on the application page in ICp
<br />![Open Jenkins URL](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/OpenJenkins.png)<br />
1. Login as user admin password admin

### Install required Plugins
1. Click `Manage Jenkins`
1. Click `Manage Plugins`
1. Navigate to the `Available` tab
1. Select `Pipeline Maven Integration Plugin` and `Docker Pipeline` and click `Install without restart`

### Configure Tools
1. From the *Manage Jenkins* screen, select `Global Tool Configuration`
1. In the *Maven* section, click `Add Maven`
1. Provide the name `maven`, select version `3.5.0`, and click `Save`


### Configure Credentials
1. From the main Jenkins welcome screen, select `Credentials` from the left hand navigation bar
<br />![Global Credentials](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/Jenkins-globalCredentialstore.png)<br />
1. Select the `_(global)` link to enter the global credentials scope
<br />![Add Credentials](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/Jenkins-Add-credentialstore.png)<br />
1. Click `Add Credentials` in the left hand navigation menu
<br />![Add Credentials](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/Jenkins-setup-user1-credentials.png)<br />
1. Leave Kind as `Username with password`, and enter `user1` as username and the password you created for this user as password
    Enter `icp-credentials` as ID and Description
1. Click OK

### Create a new pipeline
1. From the main Jenkins welcome screen, select `New item` to create a new job
<br />![Add Pipeline](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/Jenkins-NewPipelineJob.png)<br />
1. Enter `CustomerOrderServices` as item name, select `Pipeline` type and click `OK` to continue
<br />![Add Credentials](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/Jenkins-setup-user1-credentials.png)<br />
1. In General section select *This project is parameterized* and add a `string parameter`
1. Name the parameter `namespace` and enter a default value of `websphere`
<br />![Add Credentials](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/Jenkins-setup-user1-credentials.png)<br />
1. In the Build Triggers section select *Poll SCM* and give a schedule of `H/5 * * * *` to make Jenkins poll github for new commits every 5 minutes
1. In the *Pipeline* section select *Pipeline script from SCM*, and provide the following input
    * SCM: `git`
    * Repository URL: `https://github.com/ibm-cloud-architecture/refarch-jee-customerorder.git`
    * Credentials: `-none-`
    * Branch Specifier: `*/liberty`
    * Script Path: `tutorial/DevOps/Jenkinsfile`
1. Click `Save`

## Run your pipeline

You can trigger the pipeline build manually to see the all the steps executed from compile, build and deploy.
To do this, follow these steps:
1. From the main Jenkins welcome screen, click *CustomerOrderServices* to see the details of the pipeline
1. From the left hand navigation bar, select *Build with Parameters*
1. In the *Parameters* screen, select the default values and click `Build`
1. On the Status page click the build number on the left hand navigation bar
1. In the build screen, click the `Console Output` link on the left hand navigation bar
   Here you can see all the step in the pipeline job as they are executed

After the job has completed you can go back to the ICp Dashboard and validate that the application is running and accessible.


### Create your own fork
If you create your own fork of the ibm-cloud-architecture repository, you can update the code, and see how your changes are automatically picked up by Jenkins, will trigger a new build and push the updated code to ICp.
In this example, we will update a file straight from the github website. However, if you are familiar with pushing code to github using the git command line client, you can also do this.
This also assumes you have registered a user on [https://github.com](https://github.com). If you haven't done so already, please register now.

1. Go to [https://github.com/ibm-cloud-architecture/refarch-jee-customerorder](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder) and create a fork of this project
1. Update the Jenkins job to use this repository instead
1. In the github page for your fork of the repository, in the *Branch* selector, select *liberty*
1. Navigate to CustomerOrderServicesWeb/WebContent/product and open the `product.html` file
1. Click the pencil symbol in the file heading to edit the file
1. Around line 17, locate the line `<div id="catHeader" class="catHeader">Movies</div>`
    Update *Movies* to *Great movies* so the line reads
    `<div id="catHeader" class="catHeader">Great movies</div> `
1. In the *Commit changes* dialog box below, create a description of your changes. For example `Make movies great again` and click, `Commit changes`

Moving back to the Jenkins tab, you will notice that Jenkins will detect this change at the next github poll. A few minutes later your changes will be live.

