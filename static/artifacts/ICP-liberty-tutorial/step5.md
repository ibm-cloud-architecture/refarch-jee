# Step 5. Deploy the Liberty app on your IBM Cloud Private

In this final step, we are going to deploy our containerized Liberty app to our IBM Cloud Private (ICP) through the Kubernetes command line interface and the ICP Dashboard.

* [Deploy Liberty app from CLI using kubectl](#deploy-liberty-app-from-cli-using-kubectl)
    * [Clean Environment (CLI)](#clean-environment-cli)
    * [Create ConfigMaps (CLI)](#create-configmaps-cli)
    * [Deploy application (CLI)](#deploy-application-cli)
    * [Validate application (CLI)](#validate-application-cli)
* [Deploy Liberty app using Helm](#deploy-liberty-app-using-helm)

### Deploy Liberty app from CLI using kubectl

To authenticate kubectl you need to grab token and associated information from the ICp Dashboard. To do that follow these steps:

1. Verify that you are logged in to the ICP dashboard as `admin`.
2. In the top right corner in the dropdown by the username select `Configure Client`.
3. Copy the text in the textbox.
4. Paste the text into a terminal window.
5. The above set of commands sets the kubernetes CLI to work on the default namespace. However, we want to work on our **purplecompute namespace** as a best practices when working on a shared environment such as ICP. In order to get the Kubernetes CLI to work with the purplecompute namespace, run `kubectl config set-context bluedemocluster.icp-context --user=admin --namespace=purplecompute`

You are now authenticated and can use kubectl.

####  Clean Environment (CLI)

If you went through the deployment of the Customer Order Services application using the GUI above, you must clean the environment before doing the same using the CLI. For cleaning the environment:

1. From the navigation menu, select `Workloads --> Deployments`
2. Look for our deployment called `customerorderservices`
3. Click on the column `Actions` for the mentioned deployment and click on `Remove`
4. On the Remove Deployment dialog, click on `Remove Deployment`
5. From the navigation menu, select `Network Access --> Services`
6. Look for our service called `customerorderservices`
7. Click on the column `Actions` for the mentioned service and click on `Remove`
8. On the Remove Service dialog, click on `Remove Service`

####  Create ConfigMaps (CLI)

The environment specific runtime variables for the application will be held in ConfigMaps this time as opposed to plain environment variables as we did through the GUI. We use ConfigMaps to hold deployment specific variables, such that images and deployment manifests can be independent of individual deployments, making it easy to reuse the majority of assets across different environments such as pre-prod and prod. This information will include connectivity details for the Order database and the LDAP server. We will load the variables from properties files located in the tutorial/tutorialConfigFiles directory.

To create the ConfigMaps execute the following:

```
cd /home/skytap/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/
kubectl create configmap ldap --from-env-file=ldap.env
kubectl create configmap orderdb --from-env-file=orderdb.env
```
![CLI ConfigMaps](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/configmaps.png)

#### Deploy application (CLI)

In order to deploy our Customer Order Services application through the command line interface using kubectl, you need to execute:

`kubectl apply -f deployment.yaml`

![CLI deply](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/deployCLI.png)

#### Validate application (CLI)

To validate that the application is running properly, grab the external port for the customerorderservices service using kubectl
```
kubectl get service customerorderservices
```

![CLI service](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/serviceCLI.png)

In our case it is `31845`.

Using a web browser, navigate to the IP address for the Cluster with the path of `CustomerOrderServicesWeb`, so the full URL should look something this:
```
http://10.0.0.1:<Node_port>/CustomerOrderServicesWeb/
```

Verify that the page loads properly.

There are some handy kubectl commands to interrogate the application and do debugging

1. To get a list of pods
   `$ kubectl get pods`
```
NAME                                        READY     STATUS    RESTARTS   AGE
customerorderservices-3052797159-wgv0c      1/1       Running   0          24s
```
2. To see the container log of a pod
   `$ kubectl logs customerorderservices<pod-id>`
```
Launching defaultServer (WebSphere Application Server 17.0.0.2/wlp-1.0.17.cl170220170523-1818) on IBM J9 VM, version pxa6480sr4fp10-20170727_01 (SR4 FP10) (en_US)
[AUDIT   ] CWWKE0001I: The server defaultServer has been launched.
[AUDIT   ] CWWKE0100I: This product is licensed for development, and limited production use. The full license terms can be viewed here: https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/wasdev/license/base_ilan/ilan/17.0.0.2/lafiles/en.html
[AUDIT   ] CWWKG0093A: Processing configuration drop-ins resource: /opt/ibm/wlp/usr/servers/defaultServer/configDropins/defaults/keystore.xml
[WARNING ] CWWKG0011W: The configuration validation did not succeed. Found conflicting settings for defaultKeyStore instance of keyStore configuration.
  Property password has conflicting values:
    Secure value is set in file:/opt/ibm/wlp/usr/servers/defaultServer/configDropins/defaults/keystore.xml.
    Secure value is set in file:/opt/ibm/wlp/usr/servers/defaultServer/server.xml.
  Property password will be set to the value defined in file:/opt/ibm/wlp/usr/servers/defaultServer/server.xml.

[AUDIT   ] CWWKZ0058I: Monitoring dropins for applications.
[AUDIT   ] CWWKS4104A: LTPA keys created in 1.723 seconds. LTPA key file: /opt/ibm/wlp/output/defaultServer/resources/security/ltpa.keys
[AUDIT   ] CWPKI0803A: SSL certificate created in 2.228 seconds. SSL key file: /opt/ibm/wlp/output/defaultServer/resources/security/key.jks
com.ibm.net.SocketKeepAliveParameters
[AUDIT   ] CWWKT0016I: Web application available (default_host): http://customerorderservices-3052797159-wgv0c:9080/CustomerOrderServicesWeb/
[AUDIT   ] CWWKT0016I: Web application available (default_host): http://customerorderservices-3052797159-wgv0c:9080/CustomerOrderServicesTest/
[AUDIT   ] CWWKZ0001I: Application CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear started in 3.772 seconds.
[AUDIT   ] CWWKF0012I: The server installed the following features: [jsp-2.3, ejbLite-3.1, servlet-3.1, ssl-1.0, jndi-1.0, localConnector-1.0, federatedRegistry-1.0, appSecurity-2.0, jdbc-4.1, jaxrs-1.1, el-3.0, ldapRegistry-3.0, json-1.0, distributedMap-1.0, beanValidation-1.0, jpa-2.0].
[AUDIT   ] CWWKF0011I: The server defaultServer is ready to run a smarter planet.
```
3. To see some information about a given pod
   `$ kubectl describe pod customerorderservices<pod-id>`

### Deploy Liberty app using Helm

We have seen above how we can manually deploy the different pieces our Customer Order Services application deployment needs using the *kubectl* CLI. However, wouldn't it be great to deploy all pieces an application might need at once? We can do so using [Kubernetes Charts](https://github.com/kubernetes/charts) and [Helm](https://github.com/kubernetes/helm).

Helm is a tool that streamlines installing and managing Kubernetes applications. Think of it like apt/yum/homebrew for Kubernetes.

  * Helm has two parts: a client (helm) and a server (tiller)
  * Tiller runs inside of your Kubernetes cluster, and manages releases (installations) of your charts.
  * Helm runs on your laptop, CI/CD, or wherever you want it to run.

Charts are curated application definitions for Kubernetes Helm. A chart is a collection of files that describe a related set of Kubernetes resources. A single chart might be used to deploy something simple, like a memcached pod, or something complex, like a full web app stack with HTTP servers, databases, caches, and so on. Charts contain at least two things:

  * A description of the package (Chart.yaml)
  * One or more templates, which contain Kubernetes manifest files

Charts can be stored on disk, or fetched from remote chart repositories (like Debian or RedHat packages).

In our case, the Customer Order Services Kubernetes chart structure looks like the following:

```bash
├── refarch-jee-customerorder
    ├── chart
        ├── customerorderservices
            ├── templates
            │   ├── configmap.yaml
            │   ├── db2_job.yaml
            │   ├── deployment.yaml
            │   └── service.yaml
            ├── Chart.yaml
            └── values.yaml
```

* `Chart.yaml` defines the chart attributes with regards to name, version, etc.
* `configmap.yaml` defines a configmap where we store the LDAP and DB2 credentials and attributes.
* `db2_job.yaml` defines a job to populate the Customer Order Services database.
* `deployment.yaml` defines the what docker image will get deployed, where it comes from and some other attributes to it.
* `service.yaml` defines the service which will provide access to the several Customer Order Services pods the deployment created.
* `values.yaml` defines the values for the variables the other yaml files within the chart rely on. This is a configuration abstraction that makes the application deployable to different environments by just providing a different set of values.

### Install Helm Chart

In order to deploy the Customer Order Services application using helm,

1. Make sure Helm is installed and working by executing `helm version`

```
skytap@icpboot:~$ helm version
Client: &version.Version{SemVer:"v2.6.0", GitCommit:"5bc7c619f85d74702e810a8325e0a24f729aa11a", GitTreeState:"dirty"}
Server: &version.Version{SemVer:"v2.6.0", GitCommit:"5bc7c619f85d74702e810a8325e0a24f729aa11a", GitTreeState:"clean"}
```

2. Install the Customer Order Services application char by executing

```
helm install --name <release_name> -f <values.yaml> <path_to_chart_directory>
```

where

* `<release_name>` is a unique identifier used to uniquely identify each of the pieces deployed by a chart.
* `<values.yaml>` should be `~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/values.yaml` in our case. **IMPORTANT:** the values.yaml file provided is tailored for the default values used throughout this tutorial. If you decided to used others, you need to modify this values.yaml file accordingly.
* `<path_to_chart_directory>` should be `~/PurpleCompute/git/refarch-jee-customerorder/chart/customerorderservices/` in our case.

The output of this command should be the list of the different kubernetes pieces involved in the deployment of the Customer Order Services application:

```
skytap@icpboot:~$ helm install --name test \
-f ~/PurpleCompute/git/refarch-jee/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/values.yaml \
~/PurpleCompute/git/refarch-jee-customerorder/chart/customerorderservices/

NAME:   test
LAST DEPLOYED: Thu Feb  8 07:46:10 2018
NAMESPACE: default
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                        DATA  AGE
test-customerorderservices  14    1s

==> v1/Service
NAME                        CLUSTER-IP  EXTERNAL-IP  PORT(S)         AGE
test-customerorderservices  10.1.0.86   <nodes>      9080:31987/TCP  1s

==> v1beta1/Deployment
NAME                        DESIRED  CURRENT  UP-TO-DATE  AVAILABLE  AGE
test-customerorderservices  1        1        1           0          1s

==> v1/Job
NAME                 DESIRED  SUCCESSFUL  AGE
populate-cos-db-job  1        0           1s
```

Validate the application is running properly by following again the [Validate application (CLI)](#validate-application-cli) section above. Bear in mind that names and values used in that section might have now changed. For example, all kubernetes pieces will start with the unique `<release_name>` you specify during the helm install command.

# Next step

**CONGRATULATIONS!!** you have completed the tutorial.

Click [here](tutorial.md) to go to the tutorial initial page.
