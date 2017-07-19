# Hybrid Connectivity

Many legacy WebSphere customers as well as new cloud native customer require a hybrid cloud model which will keep some resources on premises. Sensitive data regulations and old systems of records (SOR) are a couple of examples as to why a customer might require a hybrid cloud deployment.

In our case, for [phase 1 and 2](https://github.com/ibm-cloud-architecture/refarch-jee#strategy) we are simulating such hybrid deployment by only lifting and shifting the WebSphere Application Server workloads to the IBM Cloud and leaving other resources on premises such as the database and the LDAP server.

The mechanism that IBM Bluemix offers to connect your cloud resources to your on-premise resources is the IBM Secure Gateway service. The [Secure Gateway Service](https://console.bluemix.net/docs/services/SecureGateway/secure_gateway.html?pos=2) provides a quick, easy, and secure solution for connecting anything to anything. By deploying the light-weight and natively installed Secure Gateway Client, you can establish a secure, persistent connection between your environment and the cloud. Once this is complete, you can safely connect all of your applications and resources regardless of their location. Rather than bridging your environments at the network level like a traditional VPN that begins with full access and must be limited from the top down, Secure Gateway provides granular access only to the resources that you have defined.

As displayed in the following diagram, the service works by using a client to connect to your Bluemix organization. Next, you add the service to your Bluemix organization. Then, by using the Secure Gateway UI or REST API you can begin creating your gateway by connecting to your client and creating a destination point to your on-premises or cloud data. To increase security, you can add application-side Transport Layer Security (TLS), which encrypts the data that travels from your app to the client. You can extend this security with client-side TLS, which encrypts the data from the client to the on-premises or cloud data. When you complete your gateway configuration, you can monitor the behavior of your gateways and destinations in the Secure Gateway Dashboard.

![Hybrid 1](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Hybrid/Hybrid1.png)

### 1. Database Integration

`TBD`

### 2. LDAP Server Integration

`TBD`
