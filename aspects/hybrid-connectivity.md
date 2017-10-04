# Hybrid Connectivity

Hybrid Cloud solutions are those that span beyond a single cloud instance. These solutions can encompass applications whose components are split across cloud and on-premises environments, or across different clouds -- even across different cloud providers. Hybrid Cloud solutions must consider issues of connectivity, latency, and standardisation across clouds, vendors, and application design. Hybrid Cloud applications also must integrate with mission-critical on-premises systems of record and other established data systems.

A successful hybrid solution must connect seamlessly to existing enterprise integration capabilities and run without preoccupation as to where the components actually reside, on-premises or native. Capabilities such as APIs, events and messaging, data integration, and security are all crucial in successful hybrid integrations.

As part of the work done in this reference architecture, including the Customer Order Services reference application, the decision was made to use [Secure Gateway](https://console.bluemix.net/catalog/services/secure-gateway) to integrate between the agile compute environment and the required backing DB2 and LDAP services in a point-to-point manner.  Depending upon client requirements, production characteristics, and other security needs, additional integration technologies may be desired, including but not limited to site-to-site VPNs and more.

<p align="center">
  <img src="https://github.com/ibm-cloud-architecture/refarch-integration/blob/master/docs/Fg1.png">
</p>

For more information on Hybrid Integration Reference Architectures, with free implementations ready to try, visit the [IBM Cloud Architecture Centre](https://www.ibm.com/devops/method/category/architectures) and the [IBM Cloud Architecture GitHub repository](https://github.com/ibm-cloud-architecture/refarch-integration).
