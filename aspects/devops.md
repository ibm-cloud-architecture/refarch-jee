# DevOps in refarch-jee


## Continuous Integration

The main purpose if the continuous integration design is to allow developers easily integrate newly developed code into the master source tree, with a high degree of confidence that new code does not lead to problems when it finds its way to the production environment.


This is done by automation in some major areas:

   1. Validating that the code does not cause merge conflicts
   2. Validating that the code compiles successfully
   3. Validating that the code passes tests where possible and applicable (unit tests, integration tests, etc)
   4. Validating that the code will successfully run in the target environment
   
It is important that the automation and processes are continuously improved, such that when a bug slips through the net and finds it's way into production the learning gained from fixing the problem is used to enhance the Continuous Integration process. Preferably this is done by enhancements to tests and automation.



### Design in refarch-jee-customerorder

When introducing a breaking change, such as adapting the code for WAS 9 which would make it incompatible with the original WAS 7 environment, a new release candidate is created.

Each release has a dev and a prod branch, such that the repository has several branches named ```<release>-dev``` and ```<release>-prod```
The current repository has the following releases and branches
   - ```was70-dev``` used for further development effort of the WebSphere 7 supporting release
   - ```was70-prod``` holding the production code of the WebSphere 7 supporting release
   - ```was90-dev``` used for further development effort of the WebSphere 9 supporting release
   - ```was90-prod``` holding the production code of the WebSphere 9 supporting release
   
There are also some additional branches that are not release specific and are there for the purpose of developing and testing pipelines and external tools, but these will not be covered here.

### Flow
   
   - Developers create a fork off the main repository
   - New code is developed and tested locally. When ready a pull request is created against the relevant ```*-dev``` branch in the main repository
   - Depending on configuration and network Github notifies Jenkins about the new pull request or Jenkins checks periodically for new pull requests
   - Jenkins pulls down the code in the pull request and looks for a file called Jenkinsfile which includes all the steps to be executed on the code
   - If all the steps completes successfully the code is automatically merged into the relevant ```*-dev``` branch

![Pull Request Flow](/static/imgs/CICD-pull-request.png)

### Use of Jenkins

#### Pull Requests - webhook or poll schedule

To trigger a Jenkins job based on a pull request, with the necessary details about the relevant pull request, we use the Jenkins plugin GitHub Pull Request Builder aka GHPRB

If the Github server has network access to the Jenkins server, this generally means that your Jenkins server is accessible to the internet or you use Github Enterprise, 
you can configure a webhook trigger in Github.
If the Github server does not have network access to the Jenkins server, such as when using public Github and on-prem Jenkins, you will need to configure a schedule for Jenkins to poll information about the repository.
More information on [Jenkins wiki](https://wiki.jenkins.io/display/JENKINS/GitHub+pull+request+builder+plugin) and [GHPRB Github Page](https://github.com/jenkinsci/ghprb-plugin)

Once the pull request is registered, Jenkins will pull down the code in the pull request and start the job specific in the Jenkinsfile

#### The job

For the current monolith the jenkins job is very simple

   1. Build the projects using maven
   2. Execute unit tests if there are any
   3. Deploy the code to WebSphere using UrbanCode Deploy plugin (more information below)
      Success returned from UCD plugin is interpreted as successful launch of ear file in WebSphere and deems the Jenkins step successful
   4. If applicaple run tests against the application running in WebSphere to validate that it works as expected
   
#### UrbanCode Deploy's role in the CI design
In the current design UrbanCode Deploy is only used as a vehicle to deploy the built application to WebSphere for validation.
This could also be done via available Jenkins plugins, or through custom jython scripts.

The UCD Server requires relevant plugins for WebSphere for this to work.
Details on these plugins here:
[WebSphere Application Server - Configure](https://developer.ibm.com/urbancode/plugin/websphere-application-server-configure/)
[WebSphere Application Server - Deployment](https://developer.ibm.com/urbancode/plugin/websphere-application-server-deployment/)

Jenkins will also require UCD plugins to work.
There are two plugins available, one for traditional jobs (post build action), and one for pipelines. 
[UCD Jenkins Publisher](https://developer.ibm.com/urbancode/plugin/jenkins/)
[UCD Jenkins 2.0 plugin for pipelines](https://developer.ibm.com/urbancode/plugin/jenkins-2-0/)

We use the pipeline plugin.


#### Configuring up the UCD Server to accept deploy requests
With the WAS plugins in place, installing the UCD Agent on a machine with WebSphere running will let UCD detect the presence of WebSphere

To prepare UCD to accept deployment requests from Jenkins follow these steps:
1. Go to the Component tab
1. Click ```Create component```
1. Select ```Websphere Application Server``` as component template
1. Fill in the form, naming the application ```CustomerOrderservicesApp```
1. Go to resources tab
1. Click ```Create top level group```
 -> name it ```Websphere```
1. Drag and drop the UCD Agent to sit under the Websphere top level group
 -> expand ```<ucd_agent_name>``` 
2. Click on the ```Actions``` button on the WebSphere resource
3. Select ```Configure using WebSphere Topology Discovery```
After a few minutes websphere details such as node, cell and server will have been populated
1. Go to the Applications tab and click ```create application```
-> name it ```CustomerServiceApp```
1. Go to the ```Components``` subtab and click ```add component```
-> select ```CustomerServicesApp```
1. Go to the Environments subtab and click ```Create environment```
-> Name it ```WASaaS-dev```
1. Click the ```WASaaS-dev``` environment
1. Click ```Add base resource```
-> Select ```Websphere``` resource
1. Expand ```Websphere -> <UCDAgentName> -> <WebSphere Cell Name> -> Servers -> Server1```
1. Click the ```Actions``` button by ```Server1``` and select ```Add component```
-> Select ```CustomerServicesApp``` from the dropdown and click Ok

You can read similar examples here: [example 1](https://developer.ibm.com/urbancode/docs/jenkins-build-step-integration-with-ibm-urbancode-deploy/)
### Configure Jenkins
Configure the Jenkins UrbanCode plugin to connect to the UCD server.
Example configuration [here](https://developer.ibm.com/urbancode/docs/integrating-jenkins-ibm-urbancode-deploy/)


## Continuous Delivery

The current design is based on delivery being handled by UrbanCode Deploy (UCD). UCD supports process flow including human gates, approval processes etc.
In this document we will not go into details about these, but rather look at how new code is made available to production.

As described above, new code is continuously tested and integrated into the central code repository.
At regular intervals (delivery train) code is merged into the production branch.

The high level flow looks like this
1. Depending on organisational structure a merge to ```*-dev``` branch, or a periodical 'delivery train schedule' will trigger merge of ```*-dev``` branch into ```*-prod```
1. The new code in ```*-prod``` will be built and pushed to UrbanCode Deploy which deploys the binaries to a QA environment.
1. Upon successful validation in QA environment, the code can be deployed to production environment using UCD

An illustration of the flow might look like this
![CD Flow](/static/imgs/CICD-repo-update.png)

This is done by a Jenkins job that goes through the following steps:
1. Check if the last commit in the development branch is a commit to update maven build version
-> if not, it means that new commits have been tested and committed and can be merged into production branch
1. merge the development branch (locally)
1. update the maven build versions (remove -SNAPSHOT)
1. Build the code using maven
1. run unit tests if applicable
1. Push the binaries to Artifactory (if applicable)
1. Push the binaries QA environment using UrbanCode (which also stores binaries in UrbanCode artifact store)
1. If successful push merge to github prod branch
1. update maven version number in dev branch

The newest binaries will now be running in the Quality Assurance environment, and UCD the binaries can be rolled out to production environment according to desired rules.

