# Phase 2 - Mitigation

This phase focuses on moving core pieces of compute-based business logic to cloud-based services while most existing database and messaging capabilities are left in-tact on the customer on-premise resources. Additional networking and security practices are usually defined during this phase, as the scenario we are entering into is a hybrid cloud scenario.

* [WebSphere Application Server as a Service (WASaaS)](#websphere-application-server-as-a-service-wasaas)
* [Code Analysis](#code-analysis)
* [Network](#network)
    * [Configuring a VPN](#configuring-a-vpn)
* [Security](#security)

## WebSphere Application Server as a Service (WASaaS)

`TBD: Document WASaaS concerns/assets/learning`

## Code Analysis

As we have already done in the previous migration phase, we are going to leverage and take the most advantage of tools already out there to help moving your compute-based business logic to cloud-based services. In other words, we are going to migrate our Customer Order Services application from on-premise resouces to execute on the [WebSphere Application Server as a Service on IBM Bluemix](https://console.ng.bluemix.net/docs/services/ApplicationServeronCloud/index.html#getting_started).

We are going to use the [Migration Toolkit for Application Binaries](https://developer.ibm.com/wasdev/downloads/#asset/tools-Migration_Toolkit_for_Application_Binaries) at first again. More specifically, we are going to run the [Analysis report](https://github.com/ibm-cloud-architecture/refarch-jee/blob/master/phases/phase1.md#analysis) to uncover potential issues when we move our existing WebSphere Application Server V9.0 applications to run on the cloud (WASaaS) rather than on on-premise resources.

For doing so, we run again the same command: `java -jar binaryAppScanner.jar binaryInputPath --analyze [OPTIONS]`.

_(I) binaryInputPath is an absolute or relative path to a J2EE archive file or directory that contains J2EE archive files._
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

## Network

`TBD: Document network concerns/assets/learning`

### Configuring a VPN

To securely connect cloud applications to on-premises or cloud-based remote locations, you can use a VPN tunnel such as the Bluemix Secure Gateway or SoftLayer Gateway as a Service.

For more information about the Bluemix Secure Gateway, see

[Getting started with the Secure Gateway](https://console.ng.bluemix.net/docs/services/SecureGateway/secure_gateway.html)
[Bluemix Secure Gateway: Yes, you CAN get there from here!](https://www.ibm.com/blogs/bluemix/2015/03/bluemix-secure-gateway-yes-can-get/)

For more information about configuring the SoftLayer Gateway as a Service, see [Help for Gateway as a Service](https://gateway-as-a-service.com/gaas/ui/help).

## Security

`TBD: Document Security concerns/assets/learning`
