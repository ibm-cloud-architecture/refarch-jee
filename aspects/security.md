# Enterprise Application Modernization through Java EE on Cloud

## Security

![Security 13](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Security/Security13.png)

1. Brown. Access your VMs. Delete Public IPs to VMs or do not requeste them. Use private network --> OpenVPN. (https://console.bluemix.net/docs/services/ApplicationServeronCloud/networkEnvironment.html#networkEnvironment)
TBD: https with ssl keys access?
2. Green. Public IP to IHS to access Application. TBD: At the http server, only redirect and use https. (the login dialog is set to CONFIDENTIAL) and then Web Container will only accept HTTPS traffic.
3. Red. LDAP connection. For now, using Secure Gateway. Look at: Encrypt WebSphere Application Server to LDAP link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step18)
4. Blue. DB Connection. For now, using Secure Gateway. Look at: Protect application server to database link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step28)
5.Purple. WAS internal Communication. Should happen on the private network on a secure manner? What if nodes are in different regions?
6. Yellow. Web Server (IHS) to App Server (WAS). DONE: LTPA for SSO with SSL. Encrypted link from Web Server to Web Containers to use only https. TBD: Authentica Web Server to Web Container link: Consider authenticating Web server to WebSphere Application Server HTTP link (https://www.ibm.com/developerworks/websphere/techjournal/1210_lansche/1210_lansche.html#step14) (TRUST network). How to configure WAS ND to use IHS rather than the web server plugin?

### 1. Authentication

Details to be added later

### 2. Authorization

Details to be added later

### 3. Hybrid Integration Security

Details to be added later
