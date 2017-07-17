# Enterprise Application Modernization through Java EE on Cloud

## Security

![Security 13](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security13.png)

1. Brown. Administration access to your WASaaS instance.
  * Delete Public IPs to VMs or do not requeste them
  * Use private network --> OpenVPN. (https://console.bluemix.net/docs/services/ApplicationServeronCloud/networkEnvironment.html#networkEnvironment)
  * TBD: https with ssl keys access to WAS admin Console?
2. Green. Application access:
  * Provide public IP to IHS to access Application.
  * HTTP Server should use https for the access login (CONFIDENTIAL in web.xml)
  * TBD: At the http server, only redirect and use https traffic to the Web Container since it will only accept HTTPS traffic (see 6)
3. Red. LDAP connection:
  * Integration: For now, using Secure Gateway for phase 1 & 2.
  * Look at: Encrypt WebSphere Application Server to LDAP link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step18)
4. Blue. DB Connection:
  * Integration: For now, using Secure Gateway for phase 1 & 2.
  * Look at: Protect application server to database link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step28)
5.Purple. WAS internal Communication:
  * Should happen on the private network on a secure manner? What if nodes are in different regions? Should be handled by WASaaS dev team.
6. Yellow. Web Server (IHS) to App Server (WAS):
  * LTPA for SSO with SSL - DONE.
  * Encrypted link from Web Server to Web Containers to use only https - DONE.
  * TBD: Authenticate Web Server to Web Container link: Consider authenticating Web server to WebSphere Application Server HTTP link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step14) (TRUST network).
  * How to configure WAS ND to use the separate IHS rather than the web server plugin?
  * Production environment to use a different IHS server than the one that comes with WAS ND?

### 1. Authentication

Details to be added later

### 2. Authorization

Details to be added later

### 3. Hybrid Integration Security

Details to be added later
