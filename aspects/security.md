# Security

The aim of this section is to highlight the security concerns to bear in mind when moving your traditional IBM WebSphere Application Server (WAS) workloads from your on-premise resources to the IBM [WebSphere Application Server in IBM Bluemix](https://console.bluemix.net/docs/services/ApplicationServeronCloud/index.html#getting_started) (WASaaS). As a result, we assume that traditional security concerns such as WAS to database link security, WAS to LDAP link security and other similar security concerns are already understood and implemented on their on-premise resources by the customer not needing to address them here again since their implementation will not vary much. In contrast, the integration between your WASaaS workloads and your on-premise resources will be addressed in this section.

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

### 3. Authentication and Authorisation `(TBD)`

  * Done by IHS using the LDAP (LDAP was before used at the WAS level)
  * Done using HTTP and SSL for data in the login dialog box.
  * LTPA token for SSO with SSL.
  * Integration: For now, using Secure Gateway for phase 1 & 2. (Documentation will be moved to hybrid connectivity readme in the main ref-jee repo)
  * Further security, look at: Encrypt WebSphere Application Server to LDAP link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step18)

### 4. Database connections `(TBD)`

  * Integration: For now, using Secure Gateway for phase 1 & 2. (Documentation will be moved to hybrid connectivity readme in the main ref-jee repo)
  * Further security, look at: Protect application server to database link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step28)

### 5. WASaaS internal communication `(TBD)`

  * Should happen on the private network on a secure manner?
  * Configure Web Containers to only use HTTP over SSL.

### 6. Http web server `(TBD): Will need Ray's help`

  * LTPA for SSO with SSL
  * Encrypted link from Web Server to Web Containers to use only https
  * Explain that IHS and WAS ND dmgr come in same VM and why is not production suitable.
  * Explain IHS server redirect/reject traffic.
  * Explain IHS and LDAP integration
  * Further security, look at: Authenticate Web Server to Web Container link: Consider authenticating Web server to WebSphere Application Server HTTP link to create a trusted network (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step14).
