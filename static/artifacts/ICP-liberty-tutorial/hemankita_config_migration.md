## WebSphere Configuration Migration

**Output: server.xml**

### Create the Liberty server.xml file

Configuration of the traditional WebSphere should be migrated to Liberty before deploying the application to Liberty. In Liberty, the runtime environment operates from a set of built-in configuration default settings, and the configuration can be specified by overriding the default settings.

For this, you can make use of available tools or it can be done manually.

#### [Eclipse based configuration migration tool]( https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Configuration_Migration_Tool)

[Eclipse-based WebSphere Configuration Migration tool](https://developer.ibm.com/wasdev/downloads/#asset/tools-WebSphere_Configuration_Migration_Tool) can be used to migrate the configuration from different types of servers to WebSphere application server. This can also be used to migrate the configuration of traditional WebSphere to Liberty.

Once this tool gets installed in your IDE, you can access it using the option Migration Tools.

![Eclipse Plugin1](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/EclipseMigToolkit.png)

Choose your environment and proceed with the migration.

![Eclipse Plugin2](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/ConfigMigToolPropsFile.png)

`./wsadmin.sh –lang jython –c “AdminTask.extractConfigProperties(‘[-propertiesFileName my.props]’)”`

After executing this command, my.props file will be generated. The properties file for this sample application can be accessed here [my.props](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1_assets/my.props)

Choose WebSphere Liberty as the target environment and continue the process.

![Eclipse Plugin3](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/ConfigMigToolTarget.png)

![Eclipse Plugin4](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/ConfigMigToolResources.png)

![Eclipse Plugin5](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/FinalServerXML.png)

At the end, you will have server.xml file generated. Save it.

After generating my.props file, you can also make use of [WebSphere Configuration Migration Toolkit: WebSphere Migration](https://ibm.biz/WCMT_Web) available online. This is just a replacement to the Eclipse plugin. Both of them works in the same way.

#### [WebSphere Configuration Migration Toolkit: WebSphere Migration](https://ibm.biz/WCMT_Web)

![Web Tool 1](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/WebTool1.png)

![Web Tool 2](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/WebTool2.png)

![Web Tool 3](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/WebTool3.png)

![Web Tool 4](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/WebTool4.png)

![Web Tool 5](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/WebTool5.png)

![Web Tool 6](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/WebTool6.png)

Finally, you will have a server.xml file generated.

#### server.xml manual modifications

Open your liberty server.xml and replace the contents of it with the one we just generated.

However, the migration tool kit doesnot have access to the code. So, some of the modification must be done manually depending on the application you deploy.

1. The feature list must be replaced with the following.

     ```
     <featureManager>
      <feature>localConnector-1.0</feature>
      <feature>jsp-2.3</feature>
      <feature>jpa-2.0</feature>
      <feature>jaxrs-1.1</feature>
      <feature>servlet-3.1</feature>
      <feature>jdbc-4.1</feature>
      <feature>ejbLite-3.1</feature>
      <feature>appSecurity-2.0</feature>
      <feature>ldapRegistry-3.0</feature>
     </featureManager>
     ```

2. Configure the http port.

     ```
     <httpEndpoint host="*" httpPort="9080" httpsPort="9443" id="defaultHttpEndpoint">
      <tcpOptions soReuseAddr="true"/>
     </httpEndpoint>
     ```

3. Modify the datasource definition, as the migration tool kit grabbed the default ones for traditional server, replace them in such a way that they are preferred for Liberty.

     ```
     <dataSource id="OrderDS" type="javax.sql.XADataSource" jndiName="jdbc/orderds">
      <jdbcDriver libraryRef="DB2Lib"/>
      <properties.db2.jcc  user="${env.DB2_USER_ORDER}" password="${env.DB2_PASSWORD_ORDER}" databaseName="${env.DB2_DBNAME_ORDER}" serverName="${env.DB2_HOST_ORDER}" portNumber="${env.DB2_PORT_ORDER}"/>
      <connectionManager agedTimeout="0" connectionTimeout="180" maxIdleTime="1800" maxPoolSize="10" minPoolSize="1" reapTime="180"/>
     </dataSource>
     <dataSource id="INDS" type="javax.sql.XADataSource" jndiName="jdbc/inds">
      <jdbcDriver libraryRef="DB2Lib"/>
      <properties.db2.jcc  user="${env.DB2_USER_INVENTORY}" password="${env.DB2_PASSWORD_INVENTORY}" databaseName="${env.DB2_DBNAME_INVENTORY}" serverName="${env.DB2_HOST_INVENTORY}" portNumber="${env.DB2_PORT_INVENTORY}"/>
      <connectionManager agedTimeout="0" connectionTimeout="180" maxIdleTime="1800" maxPoolSize="10" minPoolSize="1" reapTime="180"/>
     </dataSource>
     ```

4. jdbcDriver definition should be modified pointing the location of jars.

     ```
     <library id="DB2Lib">
      <fileset dir="${env.DB2_JARS}" includes="db2jcc4.jar db2jcc_license_cu.jar"/>
     </library>
     ```

5. As we are using LDAP in the sample application, LDAP registry definition must be added.

     ```
     <ldapRegistry id="ldap" host="${env.LDAP_HOST}" port="${env.LDAP_PORT}" baseDN="${env.LDAP_BASE_DN}" bindDN="${env.LDAP_BIND_DN}" bindPassword="${env.LDAP_BIND_PASSWORD}" realm="${env.LDAP_REALM}" ignoreCase="true" ldapType="IBM Tivoli Directory Server">
      <idsFilters groupFilter="(&amp;(cn=%v)(objectclass=groupOfUniqueNames))" groupIdMap="*:cn" groupMemberIdMap="mycompany-allGroups:member;mycompany-allGroups:uniqueMember;groupOfNames:member;groupOfUniqueNames:uniqueMember" userFilter="(&amp;(uid=%v)(objectclass=inetorgperson))" userIdMap="*:uid">
      </idsFilters>
    </ldapRegistry>
    ```
Once you are done with all these modifications, your server.xml should look like [this](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/blob/toLiberty/Common/server.xml) and the env variables are defined in [server.env](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/blob/toLiberty/Common/server.env)

### Liberty server Configuration

1. Using command prompt, go to the Liberty/bin directory.
2. Use this command, install all the missing features.

   `installUtility install server_name`

   During the installation, it prompts to accept the licenses. Please accept them.

Your server is ready now with all the necessary features installed.

### Deploying your application using Liberty server.

This can be done in two ways. You can use server.xml or dropins folder.

1. Using server.xml, you can deploy the application by adding the following lines to your server.xml.

   ```
   <application id="CustomerOrderServices" location="path/CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear" name="CustomerOrderServices"></application>
   ```
2. Instead of this, you can also deploy the application by placing the ear file in the **dropins** folder.

   `Place your ear in Liberty dir/usr/servers/server_name/dropins`
   
# Step 2. Build & run Liberty app locally

**Getting the project repository**

You can clone the repository from its main GitHub repository page and checkout the appropriate branch for this version of the application.

1. `git clone https://github.com/ibm-cloud-architecture/refarch-jee-customerorder.git`
2. `cd refarch-jee-customerorder`
3. `git checkout liberty`

Once you checked out the appropriate brach,

1. `cd Common`
2. `vi server.env.remote`
3. Replace DB2_PASSWORD_ORDER and DB2_PASSWORD_INVENTORY with **your database password**.
4. `cd ..`

Start **Docker** in your machine.

1. Build the docker image.

`docker build -t "customer-order-services:liberty" .`

You can verify your docker image using the command `docker images`. You will find the image.

```
REPOSITORY                                          TAG                 IMAGE ID            CREATED             SIZE
customer-order-services                             liberty             8c3e4d876dad        2 hours ago         424MB
```

2. Run the docker image.

`docker run -p 9080 customer-order-services:liberty`

When it is complete, you can see the below output.

```
[AUDIT   ] CWWKT0016I: Web application available (default_host): http://4963b17bece0:9080/CustomerOrderServicesWeb/
[AUDIT   ] CWWKT0016I: Web application available (default_host): http://4963b17bece0:9080/CustomerOrderServicesTest/
[AUDIT   ] CWWKZ0001I: Application CustomerOrderServicesApp-0.1.0-SNAPSHOT.ear started in 2.366 seconds.
[AUDIT   ] CWWKF0012I: The server installed the following features: [jsp-2.3, ejbLite-3.1, servlet-3.1, ssl-1.0, jndi-1.0, localConnector-1.0, federatedRegistry-1.0, appSecurity-2.0, jdbc-4.1, jaxrs-1.1, el-3.0, ldapRegistry-3.0, json-1.0, distributedMap-1.0, beanValidation-1.0, jpa-2.0].
[AUDIT   ] CWWKF0011I: The server defaultServer is ready to run a smarter planet.
```
Now you can run the application locally.

1. Go to your browser.
2. Access **http://<i>localhost</i>:<i>your port</i>/CustomerOrderServicesWeb/#shopPage**.
 
To get your port,
 - Use the command `docker ps`
 ```
 CONTAINER ID  IMAGE                             COMMAND                  CREATED             STATUS                                             
4963b17bece0   customer-order-services:liberty   "/opt/ibm/docker/d..."   3 minutes ago       Up 3 minutes        

PORTS                                     NAMES
9443/tcp, 0.0.0.0:32768->9080/tcp         distracted_shirley
 ```
 
Grab the port and replace it in the url. In this case, port will be 32768.

3. Once you access **http://<i>localhost</i>:<i>your port</i>/CustomerOrderServicesWeb/#shopPage**, it prompts you for username and password.

4. Login as the user `rbarcia` with the password of `bl0wfish`.

<p align="center">
<img src="https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/static/imgs/LibertyToolKit/AppRunningLocally.png">
</p>
