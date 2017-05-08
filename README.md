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


## Strategy

The Enterprise Application Modernization strategy that this reference implementation employs is built out through phases.  These phases, documented below, provide teams, with existing application ownership, the ability to learn and grow into Cloud Native principles, while at the same time not sacrificing Production efficiency or outages to the business.

### Phases

#### **Phase 0: Current State**

This phase is the ASIS, current state of the existing applications.  These are often on-premises, with very high-touch deployments, complicated by many different "owners" and layers of inefficiencies.  

#### **Phase 1: Modernization**

![Phase 1 Application Architecture](static/imgs/apparch-pc-phase1-onprem.png?raw=true)

Initial need to migrate to current runtimes, projects, and supporting libraries on WAS 8.5.X, as it’s an intermediate modernization step.  This phase focuses on modernizing application components to present-day versions, as well as development environments and delivery pipelines to modern practices.

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

The most practical pattern for this approach is the [Strangler Pattern](https://www.ibm.com/developerworks/cloud/library/cl-strangler-application-pattern-microservices-apps-trs/index.html), which sections off business capability to be reimplemented in a new microservice while the rest of the existing application functions as-is.  


### Techniques and Design Decisions

_TBD Cover each Aspect_

#### DevOps

Details to be added later

#### Hybrid Connectivity

Details to be added later

#### Security

Details to be added later

## Application Overview

The application is a simple store front shopping application, built during the early days of the Web 2.0 movement several years ago.  As such, it is in major need of upgrades from both the technology and business point of view.  Users interact directly with a browser-based interface and manage their cart to submit orders.  This application is built using the traditional [3-Tier Architecture](#tbd) model, with an HTTP server, an application server, and a supporting database.

There are several components of the overall application architecture:
- Details to be added later

## Repositories

- [Customer Order](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder)
  - Branch [RAD96 & WAS855](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/rad-9-6-was-8-5-5)
  - Branch [RAD96 & WAS7](https://github.com/ibm-cloud-architecture/refarch-jee-customerorder/tree/rad96-was70)
- [Inventory System](https://github.com/ibm-cloud-architecture/refarch-jee-inventorysystem)

## Getting Started

Details to be added later
