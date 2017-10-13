# Enterprise Application Modernization through Java EE on Cloud

This project provides a reference implementation for modernizing Java EE-based applications, running on present-day application servers (ie WebSphere Application Server), to run on the Cloud and outside the walls of traditional datacenters.  This is an iterative process, as these applications have traditionally grown to be quite large over time, allowing teams to adopt and build best practices as they progress.  This repository provides the content for both the overall strategy required for these types of modernizations, as well as reference implementation code that can be used to walk through the iterative process on your own.

The end result of this modernization effort is to build applications that are more nimble, more resilient, and more secure.  At the "end" of this modernization, users will generally be building microservices-based applications.  These applications contain components that are much smaller in nature, much more distributed, and much more autonomous.  However, the power of these smaller components is realized when they are able to evolve much more rapidly than the existing traditional enterprise applications.  

**Contents**
- [Strategy](#strategy)
  - [Phases](#phases)
  - [Techniques & Design Decisions](#techniques-and-design-decisions)
- [Application Overview](#application-overview)
- [Repositories](#repositories)
- [Getting Started](#getting-started)
- [Additional Resources](#additional-resources)


## Strategy

The Enterprise Application Modernization strategy that this reference implementation employs is built out through phases.  These phases, documented below, provide teams, with existing application ownership, the ability to learn and grow into Cloud Native principles, while at the same time not sacrificing Production efficiency or outages to the business.

### Phases

#### **Phase 0: Current State**

This phase is the ASIS, current state of the existing applications.  These are often on-premises, with very high-touch deployments, complicated by many different "owners" and layers of inefficiencies.  

#### **Phase 1: Modernization**

![Phase 1 Application Architecture](static/imgs/apparch-pc-phase1-onprem.png?raw=true)

Initial need to migrate to current runtimes, projects, and supporting libraries on WAS 8.5.5 or WAS 9.0, as it’s an intermediate modernization step and not a complete rearchitecture.  This phase focuses on modernizing application components to present-day versions, as well as development environments and delivery pipelines to modern practices.

#### **Phase 2: Mitigation Phase**

![Phase 2 Application Architecture](static/imgs/apparch-pc-phase2-hybrid-dev.png?raw=true)

This phase focuses on moving core pieces of compute-based business logic to cloud-based services iteratively.  This reinforces proper cloud principles, while not sacrificing production workloads and efficiency.  

Additional networking and security practices are usually defined during this phase, as legacy Enterprise teams are exposed to public cloud provider configurability for the first time.  

Most existing database and messaging capabilities are left in-tact during this phase, while the focus is on the core compute functionality in the new cloud environment.

#### **Phase 3: Production Lift & Shift**

![Phase 3 Application Architecture](static/imgs/apparch-pc-phase3-cloud-prod.png?raw=true)

A potential end goal for some Enterprise clients, the lifted application and all core critical components are moved to the cloud provider.  Additional components may still exist on-premise, and depending on latency requirements, either directly connected to the cloud provider or cached via secured, higher-latency direct connections to the on-premises resources.

Adoption of newer cloud-based services, such as newer databases and messaging capabilities, are often adopted during this phase as well.

#### **Phase 4: Evolve to Microservices**

Through iterative assessment, teams move to microservices on a per-business capability basis, depending on prioritized pain-points the existing lifted monolith is still presenting.  This is done repeatedly until the application teams can move at the speed the business requires.

![Phase 4 Application Architecture](https://github.com/ibm-cloud-architecture/refarch-jee-monolith-to-microservices/blob/master/images/purplecompute-architecture.png?raw=true)

### Techniques and Design Decisions

#### [DevOps](aspects/devops.md)

#### [Hybrid Connectivity](aspects/hybrid-connectivity.md)

#### [Security](aspects/security.md)

## Application Overview

The application is a simple store front shopping application, built during the early days of the Web 2.0 movement several years ago.  As such, it is in major need of upgrades from both the technology and business point of view.  Users interact directly with a browser-based interface and manage their cart to submit orders.  This application is built using the traditional [3-Tier Architecture](#tbd) model, with an HTTP server, an application server, and a supporting database.

Application architecture details are detailed at length in the [Customer Order](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder#application-overview) repository.

## Repositories

- [Customer Order](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder) - Main Legacy monolithic application GitHub repository
  - Branch [was70-dev](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/was70-dev) - Development branch for WebSphere Application Server V7.0 application code. Development Environment: RAD V9.6 + WAS V7.0. Builds either from RAD or using Maven.
  - Branch [was70-prod](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/was70-prod) - Production branch for WebSphere Application Server V7.0 application code. Does not contain any IDE specific file. Builds only using Maven.
  - Branch [was90-dev](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/was90-dev) - Development branch for WebSphere Application Server V9.0 application code. Development Environment: eclipse MARS 2 + WAS V9.0. Builds either from eclipse or using Maven.
  - Branch [was90-prod](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/was90-prod) - Production branch for WebSphere Application Server V9.0 application code. Does not contain any IDE specific file. Builds only using Maven.

- [Customer Order](https://github.com/ibm-cloud-architecture/refarch-jee-monolith-to-microservices) - Main microservices based application GitHub repository
  - [Legacy backend microservices](https://github.com/ibm-cloud-architecture/refarch-jee-monolith-to-microservices/tree/master/Legacy-Backend)
  - [Customer Order Service microservice repository](https://github.com/ibm-cloud-architecture/refarch-jee-micro-customer-service)
  - [Product Search Service microservice reopository](https://github.com/ibm-cloud-architecture/refarch-jee-micro-product-service)
  - [Shopping Service microservice repository](https://github.com/ibm-cloud-architecture/refarch-jee-micro-shopping-bff)

## Getting Started

These phases are iterative in nature and require the previous Phases to be completed before moving on.  In the links below, you will be able to move through the Phases of modernizing the reference application leveraging your own cloud resources.

- **Phase 1: Modernizing the Existing Application** [README](phases/phase1.md) & [Blog post](https://www.ibm.com/blogs/bluemix/2017/08/websphere-on-the-cloud-application-modernization/)
- **Phase 2: Mitigation Phase** [README](phases/phase2.md) & [Blog post](https://www.ibm.com/blogs/bluemix/2017/09/websphere-on-the-cloud-application-mitigation/)
- **Phase 3: Production Lift & Shift** (`TBD`)
- **Phase 4: Evolve to Microservices** [README](phases/phase4.md) & [Blog post](https://www.ibm.com/blogs/bluemix/2017/09/websphere-on-the-cloud-evolving-to-microservices/)

## Additional Resources

- [WebSphere... on Cloud? webinar ](https://www.ibm.com/blogs/cloud-computing/2016/05/wait-websphere-cloud/) - Learn how to "Life & Shift" your WebSphere Applications to the Cloud
- [WebSphere Application Server Migration Toolkit](https://developer.ibm.com/wasdev/docs/migration/) - The WebSphere migration toolkit provides a rich set of tools that help you migrate between versions of traditional WebSphere, to Liberty, to cloud platforms such as Liberty for Java on IBM Bluemix Instant Runtimes, and from non-IBM application servers.
- [IBM WebSphere Application Server V9.x Developer Tools](https://marketplace.eclipse.org/content/ibm-websphere-application-server-v9x-developer-tools#group-details) - An eclipse 4.x IDE for building and deploying Java EE, OSGi and Web 2.0 applications to WebSphere Application Server traditional V9.x with Java EE 7.
-[Build and continuously deliver a Java microservices app in IBM Cloud Private](https://medium.com/ibm-cloud/build-and-continuously-deliver-a-java-microservices-app-in-ibm-cloud-private-hybrid-cloud-cto-3da57dab120) - Stand up a private cloud instance, deploy DB2, MQ, and Redis services, supporting a Stock Trader application.
-[Developing microservices for IBM Cloud Private](https://www.ibm.com/developerworks/community/blogs/5092bd93-e659-4f89-8de2-a7ac980487f0/entry/Developing_microservices_for_IBM_Cloud_private?lang=en) - Explore the programming model used to build the Stock Trader application's microservices.
- [Refactor existing monolithic applications to microservices one bite at a time](https://www.ibm.com/developerworks/library/mw-1709-mulley1-bluemix/index.html) - Multi-part series covering the complex problem of refactoring monoliths into microservices step-by-step. Learn how to implement a systematic approach to refactor your monolithic applications and then run that monolith in the cloud.
