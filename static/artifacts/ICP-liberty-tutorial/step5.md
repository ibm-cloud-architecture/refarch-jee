# Step 5. Deploy the Liberty app on your IBM Cloud Private

In this final step, we are going to deploy our containerized Liberty app to our IBM Cloud Private (ICP) through the Kubernetes command line interface and the ICP Dashboard.

1. [Deploy Liberty app from GUI](#deploy-liberty-app-from-gui)
    * [Create Deployment (GUI)](#create-deployment-gui)
    * [Expose the application (GUI)](#expose-the-application-gui)
    * [Validate application (GUI)](#validate-application-gui)
2. [Deploy Liberty app from CLI using kubectl](#deploy-liberty-app-from-cli-using-kubectl)
    * [Clean Environment (CLI)](#clean-environment-cli)
    * [Create ConfigMaps (CLI)](#create-configmaps-cli)
    * [Deploy application (CLI)](#deploy-application-cli)
    * [Validate application (CLI)](#validate-application-cli)

### Deploy Liberty app from GUI

In order to deploy our Liberty app to ICP we need to:

1. Create a deployment, where we will tell ICP what docker image to deploy and how to do so.
2. Create a service to access our application.

####  Create Deployment (GUI)

1. Log in to the ICP Dashboard as user `admin` and password `admin`.
2. From the navigation menu, select `Workloads --> Deployments`.
3. Click on `Create Deployment` button on the top right corner.
4. On the General tab, provide `customerorderservices` as the name.
![gui_deployment](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment1.png)
5. On the Container Settings tab, provide a container name, image name, and port:

    * Container name: `customerorderservices`
    * Image name: `bluedemocluster.icp:8500/default/customer-order-services:liberty`
    * Container Port: `9080`

![gui_deployment2](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment2.png)
6. On the Labels tab, create a label `app` with value `customerorderservices`. This will label the deployment so that when we later create a service to access our application, the service will know what deployments (and containers) to redirect the traffic to.
![gui_deployment3](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment3.png)
7. In order for our application to work, we need to provide it with the DB2 and LDAP configuration. Previously, we used to do so by declaring such configuration on the server.env file of the Liberty Server. When we containerised our Customer Order Services application in [Containerise the app](#step3.md#containerise-the-app), we made the application independent from its configuration by packaging the application into a container which will get application's configuration injected based on the environment where it will end up running. We already saw this in [Run the Containerised app](#step3.md#run-the-containerised-app) where we would inject the configuration using environment files. In kubernetes, we do so using ConfigMaps which we will see in [Deploy Liberty app from CLI using kubectl](#deploy-liberty-app-from-cli-using-kubectl). ICP GUI does not let us load environment configuration from ConfigMaps for a deployment. As a result, we will have to declare this configuration straight into the deployment. For doing so, click on the `Environment variables` tab and declare the DB2 and LDAP variables:


| NAME                | VALUE                                 |
| ------------------- | ------------------------------------- |
| DB2_HOST_ORDER      | db2-cos-ibm-db2oltp-dev               |
| DB2_PORT_ORDER      | 50000                                 |
| DB2_DBNAME_ORDER    | ORDERDB                               |
| DB2_USER_ORDER      | admin                                 |
| DB2_PASSWORD_ORDER  | passw0rd                              |
| LDAP_HOST           | cap-sg-prd-4.integration.ibmcloud.com |
| LDAP_PORT           | 17830                                 |
| LDAP_BASE_DN        |                                       |
| LDAP_BIND_DN        | uid=casebind,ou=caseinc,o=sample      |
| LDAP_BIND_PASSWORD  | caseBindUser!                         |
| LDAP_REALM          | SampleLdapIDSRealm                    |


![gui_deployment4](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment4.png)

As you can see, _DB2_HOST_ORDER_ and _DB2_PORT_ORDER_ values have now changed. We are now using the kubernetes internal naming since we are going to deploy our application within the same namespace as where our DB2 instance is. Therefore, **kubernetes resources within the same namespace can use kubernetes internal names**.

![services](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/services.png)

8. Click on `Create`

#### Expose the application (GUI)

To be able to connect to the application, we need to create a service for it so that traffic gets redirected to the appropriate deployment and containers.

1. From the navigation menu, select `Network Access --> Services`.
2. Click on `Create Service` button on the top right corner.
3. On the General tab, fill in:

    * Name: `customerorderservices`
    * Type: `NodePort`

![gui_deployment5](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment5.png)

4. On the Ports tab, fill in:

    * Name: `http`
    * Port: `80`
    * Target Port: `9080`

![gui_deployment6](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment6.png)

5. On the Selectors tab, fill in:

    * Selector: `app`
    * Value: `customerorderservices`

![gui_deployment7](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment7.png)

The above must match the label in the deployment from the previous section so that the service recognises what deployments and containers to send traffic to.

6. Click `Create`.
7. Click on the newly created service and locate the port number for the `Node port` attribute. This port will be used to access the application below.

![gui_deployment8](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/gui_deployment8.png)

#### Validate application (GUI)

1. Open a new web browser tab and point it to the ICP ip address `10.0.0.1` appending the node port for the customerorderservices kubernetes services and the context root `CustomerOrderServicesWeb` at the end of it. The complete address should look like:
   ```
   http://10.0.0.1:<Node_port>/CustomerOrderServicesWeb/
   ```
where `<Node_port>` is the port number obtained in the last step from the previous section where you created the customerorderservices kubernetes service.

2. Validate that the shop loads with product listings.

### Deploy Liberty app from CLI using kubectl

To authenticate kubectl you need to grab token and associated information from the ICp Dashboard. To do that follow these steps:

1. Verify that you are logged in to the ICP dashboard as `admin`.
2. In the top right corner in the dropdown by the username select `Configure Client`.
3. Copy the text in the textbox.
4. Paste the text into a terminal window.

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

In our case it is `37845`.

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
