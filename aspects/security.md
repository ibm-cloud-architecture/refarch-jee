# Security

The aim of this section is to highlight the security concerns to bear in mind when moving your traditional IBM WebSphere Application Server (WAS) workloads from your on-premise resources to the IBM [WebSphere Application Server in IBM Bluemix](https://console.bluemix.net/docs/services/ApplicationServeronCloud/index.html#getting_started) (WASaaS). As a result, we assume that traditional security concerns such as WAS to database link security, WAS to LDAP link security and other similar security concerns are already understood and implemented on their on-premise resources by the customer not needing to address them here again since their implementation will not vary much. Also, Customer Order Services application's specific security can be found [here](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/blob/master/Security.md).

The diagram below depicts a common WASaaS deployment:

![Security 13](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security13.png)

where we have identified the following potential security concerns:
 
1. [Administration access to your WASaaS deployment](#1-wasaas-administration).
2. [Application access for the users](#2-application-access).
3. [Authentication and Authorisation of the users](#3-authentication-and-authorisation).
4. [Database connections for your applications](#4-database-connections).
5. [WASaaS internal communications between WAS ND dmgr and WAS nodes](#5-wasaas-internal-communication).
6. [Http Web Server](#6-http-web-server).

---------------------------------------------------

### 1. WASaaS administration

IBM WebSphere Application Server in Bluemix is a service that returns guests (virtual machines) in a shared environment for consumers to deploy applications. The number of VMs will depend upon the WebSphere Application Server plan selected, which in our case will be a **WAS ND plan**. A VPN protects the public service from generic port scans and other unsolicited network-based attacks.

This private network can be accessed using a VPN client. Using the private network is the appropriate approach not only to manage the VMs where the WASaaS has deployed all its needed WAS components right away but also to access the WAS admin console. More on the private network that WASaaS is deployed onto and the VPN client to gain access to can be found in the documentation [here](https://console.bluemix.net/docs/services/ApplicationServeronCloud/networkEnvironment.html#networkEnvironment).

### 2. Application access

We should definitily attach a public IP to the VM hosting our IBM HTTP Server which will redirect and/or reject traffic based on the security rules/policies defined in it to our WebSphere Application Server if we want our applications to be reached from the public internet. You can request a public IP address for your WebSphere server:

![Security 14](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security14.png)

When you open access to your public IP, the IP address is associated with your VM, and ports 80 and 443 are opened at the gateway. However, by default, Liberty Core, and traditional WebSphere Base servers do not open ports 80 and 443. Conversely, ports 80 and 443 are opened by default on the IBM HTTP Server. Therefore, you might need to configure your Liberty Core and traditional WebSphere Base servers to listen for application traffic on port 80/443 when you use public IP (see [Configuring transport chains](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.nd.doc/ae/trun_chain_transport.html)).

(\*) More on the IBM HTTP Server on the [last section](#6-http-web-server) at the bottom.

### 3. Authentication and Authorisation

WebSphere Application Server can enable security for the applications in your environment. This type of security provides application isolation and requirements for authenticating application users which is the other security requirement our web server must meet.

The JEE server’s authentication service includes and interacts with the following components:

* Realm: A collection of users and groups that are controlled by the same authentication policy.
* User: An individual (or application program) identity that has been defined in the Application Server. Users can be associated with a group.
* Group: A set of authenticated users, classified by common traits, defined in the Application Server.
* Role: An abstract name for the permission to access a particular set of resources in an application. A role can be compared to a key that can open a lock. Many people might have a copy of the key. The lock doesn’t care who you are, only that you have the right key.

These can be defined in several ways, being the easiest a federated repository in an internal file repository where users and groups are directly managed from the _Users and Groups_ section within the WAS admin console while the most common an standalone LDAP registry.

WebSphere Application Server encrypts authentication information so that the application server can send the data from one server to another in a secure manner. The encryption of authentication information that is exchanged between servers involves the Lightweight Third-Party Authentication (LTPA) mechanism. When accessing web servers that use the LTPA technology it is possible for a web user to re-use their login across physical servers. An IBM WebSphere server that is configured to use the LTPA authentication will challenge the web user for a name and password. When the user has been authenticated, their browser will have received a session cookie - a cookie that is only available for one browsing session. This cookie contains the LTPA token. If the user – after having received the LTPA token – accesses a server that is a member of the same authentication realm as the first server, and if the browsing session has not been terminated (the browser was not closed down), then the user is automatically authenticated and will not be challenged for a name and password. Such an environment is also called a Single-Sign-On (SSO) environment.

![Security 9](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security9.png)

However, if an intruder were to capture one of your cookies, they could potentially use the cookie to act as you. Since network traffic is often traveling over untrusted networks (consider your favorite WiFi hotspot), where capturing packets is quite easy, important Web traffic should be encrypted using SSL. This includes important cookies. Clearly, if SSL is used for all requests, the cookies are protected. However, many applications (perhaps accidentally) make some requests over HTTP without SSL, potentially exposing cookies. Fortunately, the HTTP specification makes it possible to tell the browser to only send cookies over SSL.

In the case of WebSphere Application Server, the most important cookie is the LTPA cookie, and therefore it should be configured to be sent only over SSL.

![Security 11](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security11.png)

Now, on a **production environment, the Authentication of users and the Authorisation for granting access to secure resources is usually done at the IBM HTTP Server level** so that we provide our WebSphere Application Server of an even better isolation. That is, no interaction with any of our WebSphere Application Server Network Deployment components will happen unless the user is authenticated and authorised by the IBM HTTP Server.

For more info on authenticating users and authorising their actions in the IBM HTTP Server, click [here](https://www.ibm.com/support/knowledgecenter/en/SSEQTP_8.5.5/com.ibm.websphere.ihs.doc/ihs/tihs_ldapconfig.html). We strongly recommend to secure all your communications happening both [from the IBM HTTP Server to the LDAP Server](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.ihs.doc/ihs/cihs_sslandldap.html) and [from the IBM HTTP Server to the WAS Deployment Manager](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.ihs.doc/ihs/tihs_setupsslwithwas.html) by using Secure Socket Layer (SSL). In fact, the use of SSL for authenticating users is required by the application itself by defining _CONFIDENTIAL_ the user data transport (see Customer Order Services application security documentation [here](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/blob/master/Security.md) for more information).

### 4. Database connections

WebSphere Application Server can provide access to data stored in Enterprise Information Systems (EIS) to its enterprise applications by defining Java Database Connectivity (JDBC) data sources. Any JDBC data source needs:

* A JDBC provider, which encapsulates the specific JDBC driver implementation class for access to the specific vendor database of your environment,
* The appropriate authentication and authorisation data<sup>\*</sup> to connect to the backend or resource and
* The data source properties (in our case, the database connection properties)

![Security 7](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security7.png)

(\*) _In WebSphere Application Server, Java Authentication and Authorization Service (JAAS) and Java 2 Connector (J2C) authentication aliases can be configured to hold the user ID and password that are used to connect to a backend resource. The authentication alias is then specified on the data source or connection factory in order to authenticate the user when establishing a connection._

![Security 8](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security8.png)

### 5. WASaaS internal communication

WebSphere Application Server internal communication among its different components, which may reside in different VMs like in this case, is carried out using the private network. However, any stronger security measure is always recommended. Hence, have a look at [security considerations when when in a multi-node WebSphere Application Server WebSphere Application Server Network Deployment environment](https://www.ibm.com/support/knowledgecenter/en/SSAW57_8.5.5/com.ibm.websphere.nd.doc/ae/tsec_esecarun.html)

### 6. Http web server

The [WebSphere Application Server in Bluemix Network Deployment Plan](https://console.bluemix.net/docs/services/ApplicationServeronCloud/index.html#getting_started) consists of a WebSphere Application Server Network Deployment cell environment with two or more virtual machines. The first virtual machine contains the Deployment Manager and IBM HTTP Server and the remaining virtual machines contain custom nodes (node agents) federated to the Deployment Manager.

![Security 15](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security15.png)

For configuring the IBM HTTP Server that comes out of the box with your WASaaS deployment, see this [link](https://console.bluemix.net/docs/services/ApplicationServeronCloud/systemAccess.html#configure_webserver).

**Again, having the WAS Deployment Manager and the IBM HTTP Server on the same box is not suitable for production environment. For security, they should be in separate boxes.** The reason for this is that if you need to allow public traffic to the IBM HTTP Server so that your applications can be used by users from the public internet, you are allowing public traffic to the entire box where your WAS dmgr also resides. This is not acceptable on a production environment.

`TDB: How to configure/install an external IHS Server?`

As we said previously in the [Authentication and Authorisation](#3-authentication-and-authorisation) section, the IBM HTTP Server will be responsible for authenticate users and authorise their request based on an external LDAP Server.

`TBD: How to configure your external IBM HTTP Server to authenticate and authorise using an external LDAP?`

Best security practices recommend authenticating the IBM HTTP Server to WebSphere Application Server HTTP link to create a trusted network (see [link](https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step14)). 

Even if you have chosen not to authenticate the link from the Web server to the Web container, you might want to consider encrypting it. The Web server plug-in transmits information from the Web server to the Web container over HTTP. If the request arrived at the Web server using HTTPS, the plug-in will forward the request on using HTTPS by default. If the request arrived over HTTP, HTTP will be used by the plug-in. These defaults are appropriate for most environments. There is, however, one possible exception.

In some environments, sensitive information is added to the request after it has arrived on your network. For example, some authenticating proxy servers (such as WebSEAL) augment requests with password information. Custom code in the Web server might do something similar. If that’s the case, you should take extra steps to protect the traffic from the Web server to the Web container. To force the use of HTTPS for all traffic from the plug-in, simply disable the HTTP transport from the Web container on every application server and then regenerate and deploy the plug-in. You must disable both the WCInboundDefault and the HttpQueueInboundDefault transport chains. Now, the plug-in can only use HTTPS and so it will use it for all traffic regardless of how the traffic arrived at the Web container.

![Security 12](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security12.png)

`TBD: Explain how LTPA for SSO with SSL works when doing the authentication and authorisation at the IHS Server level.`

`TBD: Explain how traffic get redirected/rejected in the IHS Server.`
