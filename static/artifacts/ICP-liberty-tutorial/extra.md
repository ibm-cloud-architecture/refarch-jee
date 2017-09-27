# Extra Credit

Now that you've got a traditional Liberty application up and running on the platform, it's time to evolve it!  The first step in approaching microservices from the current application is going to be modularization and refactoring.  This can be done easily to align along the components we have in Customer Order Services - front-end services and back-end services.

Breaking the application into two separate Liberty applications is a great next step to become more comfortable with the application and platform.  If you followed the optional Step 1, you have a fully functional development environment which you can build, test, and deploy future iterations of this application.

The logical steps you will need to complete this Extra Credit work are as follows:

1. Break down the application into 2 separate Liberty apps & containers - backend (REST & EJBs) & frontend (Dojo Javascript).

   Note you will have to solve the problem of [CORS](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing) upon moving the Javascript and REST services into separate applications.  You can see one solution to this problem via an implementation available on our [GitHub](https://github.com/ibm-cloud-architecture/refarch-jee-monolith-to-microservices)

2. Deploy Backend application through Kubernetes YAMLs (including a Service and Deployment), specifying the correct information via configMap entries as other steps in this tutorial have shown.

3. Deploy Front-End application through Kubernetes YAMLs, specifying the Backend service you will need to communicate with via configMaps.

4. Validate the new modular application works, allowing you the freedom to actively change the front-end without having to touch the back-end REST & EJB services!
