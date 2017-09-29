# Phase 4 – Evolve to Microservices

## Patterns and best practices used

This phase focuses on breaking the monolithic application into microservices and hosting them on kubernetes on Bluemix. The key goal behind breaking it into microservices is to address the current business requirements around agility, faster application/feature roll out, application performance tuning etc. 

The process of breaking a monolith application into microservices is a form of application modernization, which everyone is aware of and has been practiced by industry for a long time. Some of the key approaches from this are

1.	Not to break the complete application in one go in a big bang manner. Rather the application should be broken into microservices gradually and until the time you have completed the process, run it in conjunction with the monolith application. Over time, the amount of functionality implemented by the monolithic application shrinks until either it disappears entirely or it becomes just another microservice. This approach is also called the Strangler pattern.

2.	Break the front end and Backend. This is an approach to split the presentation layer from the business logic and data access layers. Most of the time it is easier to achieve this because of the way typical J2EE applications are developed. 
When you break the presentation layer from the business logic layer, you may need to introduce some additional code to break the direct dependency that may exist because of co-location and direct references. If there is REST service layer already existing (which is the case in this application), it is easy to separate the presentation layer from the monolith and create a separate microservice for the frontend. If there are no REST/Service layer existing, the first step would be to identify and create a REST service layer which will separate the direct dependency between the front end and business logic. 
See the challenges and steps to break and create front end micro service <Link to FrontEnd Microservice>.

3.	Extract Services from the existing monolith. Depending on the business requirements, and the technical feasibility, identify the modules that needs to be separated out as a separate microservice. 

4. Microservices for legacy backend. Sometimes, it may be impossible to modernize the application completely. Hence we may need to create some  microservices that represents the business capability of the backend legacy application. For this application we have created two microservices representing the “CustomerOrderService” and the “ProductSearchService”.  

## Existing Architecture
![J2EE Monolithic Application Architecture](https://github.com/ibm-cloud-architecture/refarch-jee/tree/master/static/imgs/apparch-pc-phase0-customerorderservices.png?raw=true)

Please refer to [customer order](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/was90-dev/README.md) application for getting an overview of the existing application that has been modernized into a microservice based architecture.


## Target Architecture
![Purple Compute Microservices based Architecture](https://github.com/ibm-cloud-architecture/refarch-jee-monolith-to-microservices/blob/master/images/purplecompute-architecture.png?raw=true)

The above monolith application has been broken down into 3 micro services. The micro services are deployed into Kubernetes cluster on Bluemix. Part of the functionality will continue to be in the legacy backend, which may be modernized over a period of time. For the time being it continues to run on Websphere Application Server.

## Steps to break the monolith
 
### Step 1 - Break the front end from Backend 
This is an approach to split the presentation layer from the business logic and data access layers. Most of the time it is easier to achieve this because of the way typical J2EE applications are developed. Here the existing DOJO based frontend has been  moved out from the main J2EE application as a separate Microservice called [Shopping WEB BFF Microservice](https://github.com/ibm-cloud-architecture/refarch-jee-micro-shopping-bff). Currently we have only Web channel through which the request is received. Hence we have created the the BFF (Backend for Frontend) Microservice for Web. In future if we need to cater to mobile channel, we can create another BFF Microservice for mobile to cater to the requirement. Find below the steps and challenges for breaking the frontend from Backend and creating it as a separate Microservice.

#### Shopping WEB BFF Microservice
A new microservice called [Shopping WEB BFF Microservice](https://github.com/ibm-cloud-architecture/refarch-jee-micro-shopping-bff) was created by copying the code from the CustomerOrdersServiceWeb project to recreate the front end. In the existing Web Frontend code, the web application was making direct EJB references to the EJBs as they were running in the same server. When we separate out the front end and make it a separate microservice, we needed to make changes to it. Instead of making direct calls, we had to make REST API calls to the backend micro services. This introduced the [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) challenge. The web client is written in Dojo. In Dojo, relative path is used to call a REST interface. And this method is useful for rest interfaces that are implemented/deployed within the same domain. If the REST interfaces are available across domain then the relative path approach does not work. Using JSONP approach is a way to achieve cross domain REST invocations. However for this approach to work, server side changes are required.


What is CORS:
From Wiki - [Cross-origin resource sharing (CORS)](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) is a mechanism that allows restricted resources (e.g. fonts) on a web page to be requested from another domain outside the domain from which the first resource was served.A web page may freely embed cross-origin images, stylesheets, scripts, iframes, and videos. Certain "cross-domain" requests, notably Ajax requests, however are forbidden by default by the same-origin security policy.CORS defines a way in which a browser and server can interact to determine whether or not it is safe to allow the cross-origin request. It allows for more freedom and functionality than purely same-origin requests, but is more secure than simply allowing all cross-origin requests. It is a recommended standard of the W3C.


Hence to overcome this issue Java code is introduced in the same project as the dojo code is in, so that the dojo code can call the interface exposed by java code within the same project and in turn java code can invoke cross domain calls. There are multiple ways CORS issue can be handled. In this case we created another layer of redirection such that the front end makes calls to a routing module deployed along with the front end service, which in turn makes the REST calls to the backend microservices.

#### Steps
1. A microservice was created by copying the existing Web front end code
2. A simple Java class is written to proxy the backend microservices - that the DOJO frontend can invoke (to get around CORS challenge)

### Step 2 – Identify and create Microservices for Backend and apply Strangler pattern
The application was analyzed and modules were identified using domain driven design approach. For the above application we identified two key modules namely 
[CustomerOrder Microservice](https://github.com/ibm-cloud-architecture/refarch-jee-micro-customer-service) and [ProductSearch Microservice](https://github.com/ibm-cloud-architecture/refarch-jee-micro-product-service) (As represented by "KUBERNETES BACKEND SERVICES" block in the above target architecture diagram). We created two Microservices for each of these two services. Even though currently the microservice only work as service routers, we can use [strangler pattern](https://www.ibm.com/developerworks/cloud/library/cl-strangler-application-pattern-microservices-apps-trs/index.html) over a period of time to move/modernize some of the capabilities from the backend into these microservices. 

E.g. Now the backend services has ProductSearch module. This service could be written separately altogether using new technologies, like nodejs and nosql. For the new APIs to be used, there's only a minor change that needs to be done in ProductSearch Microservice. No changes whatsoever are required in any other module. Similarly it can be extended to any existing APIs and new APIs.

### Step 3 – Breaking the backend application into Separate EARs
Instead of having a monolithic app as a single EAR, it was percived that the application should be broken into logical units so that we can take it towards a microservice architecture and have better control over individual functionalities of the application. Hence the single EAR was broken into two EARS having one EJB each. These EJBs are called CustomerOrder EJB and ProductSearch EJB. 


#### Steps followed to break it into 2 EARs
The multiple EJB  Business functionality included in the same EAR has been split into individual JEE EJB packages using the following steps:
* Create a directory ProductSearchService and copy the CustomerOrderServices content into that. 
* Delete the ProductSearchService and ProductSearchServiceImpl class from CustomerOrderServices ejbmodule directory.  
* Delete CustomerOrderServices and CustomerOrderServicesImpl from ProductSearchService ejbmodule directory.
* There is no change in the utility classes used in both the modules
 
#### Steps followed to expose them to the outside world as Services
The wrapper classes are used to expose the EJB REST API Java classes in the respective WebModules CustomerOrderServicesWeb and ProductSearchServiceWeb to access from outside. The steps required to do the same are
* Create a directory ProductSearchServiceWeb and copy the contents of CustomerOrderServicesWeb into it.  
* Rename the CustomerServicesApp class as ProductSearchServiceApp class for ProductSearchServiceWeb module Java src folder and remove the CustomerOrderResource class in it.
* Remove the CategoryResource and ProductResource from CustomerOrderServicesWeb.
* Delete WebContent from both the modules. Modify the pom.xml file accordingly

### Step 4 - Handle Application Security
When you refactor your application into Microservices, your traditional application security mechanism may not work. As a sample implementation, we have used Open LDAP as our directory server and SSO provider, which can federate access to different microservices and pass on the access context appropriately. For the shopping application, we have used Liberty as the implementation runtime. Appropriate changes were made to the server configuruation files (Server.xml) to enable SSO and use OLDAP as the SSO service provider. The detail steps are discussed [here](Legacy-Backend/SSO_OpenLDAP_Configuration.md).
