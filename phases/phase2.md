# Phase 2 - Mitigation

This phase focuses on moving core pieces of compute-based business logic to cloud-based services while most existing database and messaging capabilities are left in-tact on the customer on-premise resources. Additional networking and security practices are usually defined during this phase, as the scenario we are entering into is a hybrid cloud scenario.

* [WebSphere Application Server as a Service (WASaaS)](#websphere-application-server-as-a-service-wasaas)
* [Code Analysis](#code-analysis)
* [Hybrid Integration](#hybrid-integration)
* [Security](#security)

## WebSphere Application Server as a Service (WASaaS)

[IBM® WebSphere Application Server in IBM® Bluemix®](https://console.ng.bluemix.net/docs/services/ApplicationServeronCloud/index.html#getting_started) is a service that facilitates quick setup on a pre-configured WebSphere Application Server Liberty, Traditional Network Deployment, or Traditional WebSphere Java EE instance in a hosted cloud environment on Bluemix on a virtual machine guests with root access to the guest operating system.

The WebSphere Application Server in Bluemix Network Deployment Plan consists of a WebSphere Application Server Network Deployment cell environment with two or more virtual machines. The first virtual machine contains the Deployment Manager and IBM HTTP Server and the remaining virtual machines contain custom nodes (node agents) federated to the Deployment Manager.

![WASaaS Image 1](/phases/phase2_images/WAS1.png?raw=true)

IBM WebSphere Application Server in Bluemix is a service that returns guests (virtual machines) in a shared environment for consumers to deploy applications. A VPN protects the public service from generic port scans and other unsolicited network-based attacks. However, it is important to note that **the service VPN you use to access your service instance might be shared between multiple Bluemix organizations and users.**

![WASaaS Image 2](/phases/phase2_images/WAS2.png?raw=true)

### Network

After your WebSphere Application Server in Bluemix service instance is provisioned, you can access your VM in several ways. You can connect over a secure VPN to get SSH, traditional WebSphere Admin Console, and application access to your VM. You can also connect your VM to the internet with a public IP address.

![Network Image 1](/phases/phase2_images/Network1.png?raw=true)

#### Private VPN Access

The VPN configuration is scoped to your organization and region. It is valid for one year from the time created. Multiple OpenVPN client connections can be established simultaneously by using the same VPN configuration. You connect to your VM's private IP address over the VPN connection. Your Liberty Admin Center (9080, 9443), traditional WebSphere Admin Console (9060, 9043), SSH (22), and ports other than 80/443 are only accessible through the VPN connection.

Any agent installed (monitoring, management such as UCD, database connection, etc) needs explicit port open on OUTPUT chain to work. That is, you need to open the ports you need for INPUT and/or OUTPUT in the **iptables** of your WAS VM.

#### Public Internet Access

Optionally, you can request a public IP address for your WebSphere server VM. When you open access to your public IP, the IP address is associated with your VM, and ports 80 and 443 are opened at the gateway. However, by default, Liberty Core, and traditional WebSphere Base servers do not open ports 80 and 443. Conversely, ports 80 and 443 are opened by default on the IBM HTTP Server. Therefore, you might need to [configure your Liberty Core and traditional WebSphere Base servers to listen for application traffic on port 80/443](https://www.ibm.com/support/knowledgecenter/SSEQTP_8.5.5/com.ibm.websphere.nd.doc/ae/trun_chain_transport.html) when you use public IP.

## Code Analysis

As we have already done in the previous migration phase, we are going to leverage and take the most advantage of tools already out there to help moving your compute-based business logic to cloud-based services. In other words, we are going to migrate our Customer Order Services application from on-premise resouces to execute on the [WebSphere Application Server as a Service on IBM Bluemix](https://console.ng.bluemix.net/docs/services/ApplicationServeronCloud/index.html#getting_started).

We are going to use the [Migration Toolkit for Application Binaries](https://developer.ibm.com/wasdev/downloads/#asset/tools-Migration_Toolkit_for_Application_Binaries) at first again. More specifically, we are going to run the [Analysis report](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1.md#analysis) to uncover potential issues when we move our existing WebSphere Application Server V9.0 applications to run on the cloud (WASaaS) rather than on on-premise resources.

For doing so, we run again the same command: `java -jar binaryAppScanner.jar binaryInputPath --analyze [OPTIONS]`.

_(I) binaryInputPath is an absolute or relative path to a JEE archive file or directory that contains JEE archive files._
_(II) in this case, we need to update the options to the current WebSphere Application Server version as well as to the target IBM platform. That is, our [OPTIONS] this time are: `--sourceAppServer=was90 --targetAppServer=was90 --sourceJava=ibm8 --targetJava=ibm8 --targetJavaEE=ee7 --targetCloud=wasVM`_

[**Report**](http://htmlpreview.github.com/?https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase2_reports/CustomerOrderServicesApp.ear_AnalysisReport.html)

![Analyze report](/phases/phase2_images/analyze_report/Analyze1.png?raw=true)

We can see in the report that the issues in the green boxes were already reported during the previous [code migration phase](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1.md#analysis) in which these were already addressed. The reason for these issues to appear again in the report is because we did not address them per se since we are 'lifting & shifting' our existing old WebSphere Application Server applications running on existing on-premise resources to a newer WebSphere Application Server version and different IBM platform. That is, we want to do that 'lift & shift' the simplest and least intrusive. This means to do the least changes to the code or structure of the applications as well as reuse as most as possible the same Java Technologies and versions of them as long as the new WebSphere Application Server version and IBM platform support them.

We are then left with three potential issues if we run our applications on the WebSphere Application Server as a Service on IBM Bluemix as it is. Let's have a closer look at them.

![Analyze report 2](/phases/phase2_images/analyze_report/Analyze2.png?raw=true)

The _Analyze report_ flags the use of databases in our applications since they will not be accessible as they are configured so far once we move our applications to the cloud. We can also see that the _Analyze report_ itself provides a possible solution for this problem.

![Analyze report 3](/phases/phase2_images/analyze_report/Analyze3.png?raw=true)

Database issue is, however, an environment configuration problem rather than a code issue. Therefore, we need to configure a [VPN tunnel](#configuring-a-vpn) to connect our compute-based resources on the cloud with our on-premise databases. In our case, we have set up [Secure Gateway on Bluemix](https://console.ng.bluemix.net/docs/services/SecureGateway/secure_gateway.html) and configure our WASaaS instances to connect to our on-premise database.

![Analyze report 4](/phases/phase2_images/analyze_report/Analyze4.png?raw=true)

JavaEE Security is another issue that the _Analyze report_ flags since the source users of your applications use for Authorization and Authentication might be impacted. For instance, your organisation might use an LDAP server to implement the security registry of your application users. This LDAP server must be accessible by your WASaaS instances too.

![Analyze report 5](/phases/phase2_images/analyze_report/Analyze5.png?raw=true)

Again, we can see that the _Analyze report_ itself suggest a solution for this problem too and that this is, again, to use a [VPN tunnel](#configuring-a-vpn)

![Analyze report 6](/phases/phase2_images/analyze_report/Analyze6.png?raw=true)

We configure our WASaaS instances to use the same [Secure Gateway on Bluemix](https://console.ng.bluemix.net/docs/services/SecureGateway/secure_gateway.html) service to connect to our on-premise LDAP server.

Finally, the last issue the _Analyze report_ flags is the validation of the URL host and port used in our application. Since the application will be living in a different platform, we are asked to review all the URL hosts and posts which, ideally, should be extracted out to properties files instead of hard-coded so that they can be changed based on where the applications get deployed.

![Analyze report 7](/phases/phase2_images/analyze_report/Analyze7.png?raw=true)

Looking at the code, we made sure we do not have hard-coded URLs at all. Instead, we declare the values which will form the URL as environment variables whose value can change from one deployment to another.

![Analyze report 8](/phases/phase2_images/analyze_report/Analyze8.png?raw=true)

The URLs being flagged by the _Analyze report_ belong to the catch section of the Java code in case any exception happens when reading reading the environment variables.

![Analyze report 9](/phases/phase2_images/analyze_report/Analyze9.png?raw=true)

In summary, migrating your WebSphere Application Server applications from your on-premise resources to WebSphere Application Server as a Service (WASaaS) on Bluemix requires a detailed verification on:

1. On-premise resources your applications will still need to connect to like databases or security registries. For that, IBM Bluemix offers services like [Secure Gateway](https://console.ng.bluemix.net/docs/services/SecureGateway/secure_gateway.html)
2. URL hosts and ports used by your applications since they won't be running on the same well known static resources and won't use same ports.

## Hybrid Integration

We are moving our compute-based traditional WAS resources to the cloud but we still need them to securely connect to our on-premise resources so that they can access application data and security registries for authentication and authorization purposes.

To securely connect cloud applications to on-premises or cloud-based remote locations, you could use a VPN tunnel such as the [IBM Bluemix Secure Gateway](https://console.ng.bluemix.net/docs/services/SecureGateway/secure_gateway.html) or the [SoftLayer Gateway as a Service](https://gateway-as-a-service.com/gaas/ui/help).


* [Bluemix Secure Gateway: Yes, you CAN get there from here!](https://www.ibm.com/blogs/bluemix/2015/03/bluemix-secure-gateway-yes-can-get/)

In our case, we have configured our WebSphere Application Server as a Service instances to use the IBM Bluemix Secure Gateway service to connect the application server, and so its applications, to our on-premise DB2 database instance and LDAP server.

The [Secure Gateway Service](https://console.bluemix.net/docs/services/SecureGateway/secure_gateway.html?pos=2) provides a quick, easy, and secure solution for connecting anything to anything. By deploying the light-weight and natively installed Secure Gateway Client, you can establish a secure, persistent connection between your environment and the cloud. Once this is complete, you can safely connect all of your applications and resources regardless of their location. Rather than bridging your environments at the network level like a traditional VPN that begins with full access and must be limited from the top down, Secure Gateway provides granular access only to the resources that you have defined.

As displayed in the following diagram, the service works by using a client to connect to your Bluemix organization. Next, you add the service to your Bluemix organization. Then, by using the Secure Gateway UI or REST API you can begin creating your gateway by connecting to your client and creating a destination point to your on-premises or cloud data. To increase security, you can add application-side Transport Layer Security (TLS), which encrypts the data that travels from your app to the client. You can extend this security with client-side TLS, which encrypts the data from the client to the on-premises or cloud data. When you complete your gateway configuration, you can monitor the behavior of your gateways and destinations in the Secure Gateway Dashboard.

![Hybrid 1](https://github.com/ibm-cloud-architecture/refarch-jee/raw/master/static/imgs/Hybrid/Hybrid1.png)

Once your Secure Gateway client is linked to the Secure Gateway Service in Bluemix, you get an endpoint from the latter to connect all your cloud resources to in order to access your on premise resources. Next is an example of how you would configure your WebSphere Application Server as a Service instances to your on premise resources by using the Secure Gateway endpoint.

For the DB2 database

![Hybrid 2](/phases/phase2_images/analyze_report/Analyze4.png?raw=true)

and LDAP server

![Hybrid 3](/phases/phase2_images/Hybrid1.png?raw=true)

For more info on hybrid cloud architectures see 

## Security

Customer Order Services application security details can be found [here](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/blob/master/Security.md) in its GitHub repository. Security main points include:

* Authenticate users using an LDAP server, which is located on premises and accessed through the Secure Gateway service explained in the previous section.
* Authorize users based on their role.
* Use LTPA tokens to encrypt athentication information exchanged by servers.

For more info on the security mechanisms and considerations for both the application and the web server, read the [Secuity aspect readme](/aspects/security.md)
