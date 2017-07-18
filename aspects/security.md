# Security

The aim of this section is to highlight the security concerns to bear in mind when moving your traditional WebSphere Application Server workloads from your on-premise resources to the WebSphere as a Service service in IBM Bluemix. As a result, we assume that traditional security concerns such as WAS server to DB link security, WAS server to LDAP link security and other similar security concerns are already clearly understood and implemented by the customer on their on-premise deployments which will not vary to those in WASaaS in IBM Bluemix. However, the integration between your WASaaS workloads and your on-premise resources will be addressed in this section.

The diagram below depics a common WASaaS deployment:

![Security 13](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security13.png)

where we see the following potential security concerns:
 
1. Administration access to your WASaaS deployment.
2. Application access for the users.
3. Authentication and Authorisation of the users.
4. Database connections for your applications.
5. WASaaS internal communications between WAS ND dmgr and WAS nodes.
6. Http Web Server.

---------------------------------------------------

### 1. WASaaS administration

  * Delete Public IPs to VMs or do not requeste them (this should be done by CD scripts) (TBD)
  * Use private network to connect to VMs for administration. OpenVPN. Bluemix documentation:  (https://console.bluemix.net/docs/services/ApplicationServeronCloud/networkEnvironment.html#networkEnvironment) (DONE. Just add documentation)
  * Https with ssl keys to access the WAS admin Console? (TBD)

### 2. Application access

  * Provide public IP to IHS to access Application (this should be done by CD scripts) (TBD)
  * HTTP Server should reject http connections. Use only https requests to access the app since the app security transport layer is configured to use https for the login dialog box and web resources (CONFIDENTIAL in web.xml). Also, the Web Containers are configured in WAS admin console to only receive https traffic (see 6 below) (TBD)

### 3. Authentication and Authorisation

  * Configure IHS to A&A users by using LDAP at that level =rather than at the WAS level. (TBD)
  * Integration: For now, using Secure Gateway for phase 1 & 2. (DONE)
  * Look at: Encrypt WebSphere Application Server to LDAP link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step18) (TBD)

### 4. Database connections

  * Integration: For now, using Secure Gateway for phase 1 & 2. (DONE)
  * Look at: Protect application server to database link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step28) (TBD)

### 5. WASaaS internal communication

  * Should happen on the private network on a secure manner? What if nodes are in different regions? Should be handled by WASaaS dev team. (TBD add documentation?)

### 6. Http web server

  * LTPA for SSO with SSL (DONE in the WAS admin console)
  * Encrypted link from Web Server to Web Containers to use only https (DONE in the WAS admin console)
  * Authenticate Web Server to Web Container link: Consider authenticating Web server to WebSphere Application Server HTTP link to create a trusted network (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step14) (TBD).
  * How to configure WAS ND to use the separate IHS rather than the web server plugin? (TBD)
  * Production environment to use a different IHS server than the one that comes with WAS ND? (TBD)
  
---------------------------------------------------
