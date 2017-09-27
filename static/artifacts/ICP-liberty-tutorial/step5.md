# Step 5. Deploy the Liberty app on your IBM Cloud Private

In this final step, we are going to deploy our containerized Liberty app to our IBM Cloud Private (ICP) through the Kubernetes command line interface and the ICP Dashboard.

1. [Deploy Liberty app from GUI](#deploy-liberty-app-from-gui)
    * [Create ConfigMaps (GUI)](#create-configmaps-gui)
    * [Deploy application (GUI)](#deploy-application-gui)
    * [Expose the application (GUI)](#expose-the-application-gui)
    * [Validate application (GUI)](#validate-application-gui)
2. [Deploy Liberty app from CLI using kubectl](#deploy-liberty-app-from-cli-using-kubectl)
    * [Clean Environment (CLI)](#clean-environment-cli)
    * [Create ConfigMaps (CLI)](#create-configmaps-cli)
    * [Deploy application (CLI)](#deploy-application-cli)
    * [Validate application (CLI)](#validate-application-cli)

### Deploy Liberty app from GUI

In order to deploy our Liberty app through the ICP Dashboard, we must first log in to ICP Dashboard with username `user1` and the password you created in the previous step.

####  Create ConfigMaps (GUI)

The environment specific runtime variables for the application will be held in ConfigMaps. We use ConfigMaps to hold deployment specific variables, such that images and deployment manifests can be independent of individual deployments, making it easy to reuse the majority of assets across different environments such as pre-prod and prod. This information will include connectivity details for the Order database, the Inventory database and the LDAP server.

1. Log in to the ICp Dashboard as user `user1`.
2. From the navigation menu, select `Workloads --> Configs`.

**Order DB Configmap**

1. Click Create Configmap.
2. In the dialog box, provide the name `orderdb`.
3. Toggle the `JSON mode` button to enter into JSON mode.
4. In the `data` JSON parameter, enter the following JSON snippet as its value.

    ```
    "DB2_HOST_ORDER": "10.0.0.7",
    "DB2_PORT_ORDER": "50000",
    "DB2_DBNAME_ORDER": "ORDERDB",
    "DB2_USER_ORDER": "db2inst1",
    "DB2_PASSWORD_ORDER": "db2user01"
    ```
![orderdb ConfigMap Json](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/orderdbConfigMapJson.png)

5. Click `Create`.

**Inventory DB Configmap**

1. Click Create Configmap.
2. In the dialog box, provide the name `inventorydb`.
3. Toggle the `JSON mode` button to enter into JSON mode.
4. in the `data` JSON parameter, enter the following JSON snippet as its value.

    ```
    "DB2_HOST_INVENTORY": "10.0.0.7",
    "DB2_PORT_INVENTORY": "50000",
    "DB2_DBNAME_INVENTORY": "INDB",
    "DB2_USER_INVENTORY": "db2inst1",
    "DB2_PASSWORD_INVENTORY": "db2user01"
    ```

![indb ConfigMap Json](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/indbConfigMapJson.png)

5. Click `Create`.

**LDAP Configmap**

1. Click Create Configmap.
2. In the dialog box, provide the name `ldap`.
3. Toggle the `JSON mode` button to enter into JSON mode.
4. in the `data` JSON parameter, enter the following JSON snippet as its value.

    ```
    "LDAP_HOST": "cap-sg-prd-4.integration.ibmcloud.com",
    "LDAP_PORT": "17830",
    "LDAP_BASE_DN": "",
    "LDAP_BIND_DN": "uid=casebind,ou=caseinc,o=sample",
    "LDAP_BIND_PASSWORD": "caseBindUser!",
    "LDAP_REALM": "SampleLdapIDSRealm"
    ```

![ldap ConfigMap Json](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/ldapConfigMapJson.png)

5. Click `Create`.

#### Deploy application (GUI)

When deploying the application from GUI you will see that the interface will create a similar deployment manifest as you created in step 4, but in JSON format.

You can compare the JSON that the GUI creates with the yaml you created in step 4 to see the similarities.

1. From the navigation menu, select `Workloads --> Applications`.
2. Select Deploy Application.
3. On the General tab, provide `customerorderservices` as the application name.
4. On the Container Settings tab, provide a container name, image name, and port:
    
    * Container name: customerorderservices
    * Image name: mycluster:8500/websphere/customer-order-services:liberty
    * Container Port: 9080

5. To be able to expose the information we stored in the ConfigMaps we need to create some entries in the JSON files manually. Therefore, toggle the `JSON mode` button to enter into JSON mode.
6. Within the `containers` attribute, where the deployment definition lists all the containers to be deployed, we should find only one conatiner. This container should be named `customerorderservices`. In order to get this container to read the config maps we created before, we need to add the following attribute below the `port` attribute to the container definition:
    
    ```
    "envFrom": [
        {
            "configMapRef": { "name": "orderdb" }
        },
        {
            "configMapRef": { "name": "inventorydb" }
        },
        {
            "configMapRef": { "name": "ldap"}
        }
    ],

    ```
    
![Deploy Json](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/DeployJSON.png)

7. Select Deploy.

#### Expose the application (GUI)

To be able to connect to the application from our workstation we need to expose the application to the external network.

1. From the `Workloads --> Applications` view, click on the settings wheel under the `ACTION` column for the `cusotmerorderservices` application and select `Expose`.
2. Fill in Expose method, Port and Target Port. The other fields can be left blank or as default values

    * Expose method: ClusterIP
    * Port: 80
    * Target Port: 9080
    
 3. Click `Expose`.   

#### Validate application (GUI)

1. From the `Workloads --> Application` view, locate the application and click on the application name, customerorderservices. 
2. In the Application Overview page, locate the `Expose Details` section.
3. Grab the `Cluster IP` ip address.
4. Open a new web browser tab and point it to the `Cluster IP` ip address from previous step appending `CustomerOrderServicesWeb` at the end of it. The complete address should look like:
   ```
   http://10.0.1.127/CustomerOrderServicesWeb/
   ```
5. Validate that the shop loads with product listings.

### Deploy Liberty app from CLI using kubectl

To authenticate kubectl you need to grab token and associated information from the ICp Dashboard. To do that follow these steps:

1. Verify that you are logged in to the ICp dashboard as `user1`.
2. In the top right corner in the dropdown by the username select `Configure Client`.
3. Copy the text in the textbox.
4. Paste the text into a terminal window.

You are now authenticated and can use kubectl.

####  Clean Environment (CLI)

If you went through the deployment of the Customer Order Services application using the GUI above, you must clean the environmnet before doing the same using the CLI. For cleaning the environment you must execute the following on your terminal:

```
kubectl delete all --all
kubectl delete configmaps --all
```

![Clean Env](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/cleanenv.png)

####  Create ConfigMaps (CLI)

The environment specific runtime variables for the application will be held in ConfigMaps. We use ConfigMaps to hold deployment specific variables, such that images and deployment manifests can be independent of individual deployments, making it easy to reuse the majority of assets across different environments such as pre-prod and prod. This information will include connectivity details for the Order database, the Inventory database and the LDAP server. We will load the variables from properties files located in the tutorial/tutorialConfigFiles/step5 directory.

To create the ConfigMaps execute the following:
    
```
cd /home/skytap/PurpleCompute/git/refarch-jee-customerorder/tutorial/tutorialConfigFiles/
kubectl create configmap ldap --from-env-file=ldap.env
kubectl create configmap inventorydb --from-env-file=inventorydb.env
kubectl create configmap orderdb --from-env-file=orderdb.env
```
![CLI ConfigMaps](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/configmaps.png)

#### Deploy application (CLI)

In order to deploye our Customer Order Services application through the command line interface using kubectl, you need to execute:

```
cd step5
kubectl apply -f deployment.yaml
```

![CLI deply](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/deployCLI.png)

#### Validate application (CLI)

To validate that the application is running properly, grab the Clusters IP address using kubectl
```
kubectl get service customerorderservices
```

![CLI service](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/ICp/serviceCLI.png)


Using a web broswer, navigate to the IP address for the Cluster with the path of `CustomerOrderServicesWeb`, so the full URL should look something this:
```
http://10.0.1.9/CustomerOrderServicesWeb/
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
