# Enterprise Application Modernization through Java EE on Cloud

## Security

![Security 13](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security13.png)

1. Brown. Administration access to your WASaaS instance.
  * Delete Public IPs to VMs or do not requeste them (this should be done by CD scripts) (TBD)
  * Use private network to connect to VMs for administration. OpenVPN. Bluemix documentation:  (https://console.bluemix.net/docs/services/ApplicationServeronCloud/networkEnvironment.html#networkEnvironment) (DONE. Just add documentation)
  * Https with ssl keys to access the WAS admin Console? (TBD)

2. Green. Application access:
  * Provide public IP to IHS to access Application (this should be done by CD scripts) (TBD)
  * HTTP Server should reject http connections. Use only https requests to access the app since the app security transport layer is configured to use https for the login dialog box and web resources (CONFIDENTIAL in web.xml). Also, the Web Containers are configured in WAS admin console to only receive https traffic (see 6 below) (TBD)

3. Red. LDAP connection:
  * Configure IHS to A&A users by using LDAP at that level =rather than at the WAS level. (TBD)
  * Integration: For now, using Secure Gateway for phase 1 & 2. (DONE)
  * Look at: Encrypt WebSphere Application Server to LDAP link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step18) (TBD)

4. Blue. DB Connection:
  * Integration: For now, using Secure Gateway for phase 1 & 2. (DONE)
  * Look at: Protect application server to database link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step28) (TBD)

5.Purple. WAS internal Communication:
  * Should happen on the private network on a secure manner? What if nodes are in different regions? Should be handled by WASaaS dev team. (TBD add documentation?)

6. Yellow. Web Server:
  * LTPA for SSO with SSL (DONE in the WAS admin console)
  * Encrypted link from Web Server to Web Containers to use only https (DONE in the WAS admin console)
  * Authenticate Web Server to Web Container link: Consider authenticating Web server to WebSphere Application Server HTTP link to create a trusted network (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step14) (TBD).
  * How to configure WAS ND to use the separate IHS rather than the web server plugin? (TBD)
  * Production environment to use a different IHS server than the one that comes with WAS ND? (TBD)
  
  
---------------------------------------------------

### 1. Authentication

Details to be added later

### 2. Authorization

Details to be added later

### 3. Hybrid Integration Security

Details to be added later
