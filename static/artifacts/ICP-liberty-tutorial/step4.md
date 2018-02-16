# Step 4. Write Kubernetes YAMLs, including Deployment and Services stanzas

In this step, we are going to write the needed configuration files, deployment files, etc for a container orchestrator such as Kubernetes to get our Liberty app appropriately deployed onto our virtulized infrastructure.

1. [Push image to ICP Image Repository](#push-image-to-icp-image-repository)
    * [Create user and namespace](#create-user-and-namespace)
    * [Re-Tag image](#re-tag-image)
    * [Push image](#push-image)
2. [Generate deployment yaml file](#generate-deployment-yaml-file)

### Push image to ICP Image Repository

IBM Cloud Private (ICP) provides a docker compatible image repository out of the box, which is available on the server `bluedemocluster.icp` port `8500`.

#### Re-Tag image

To be able to push the image we build in the previous step into the ICP Image Repository, we'll need to add an additional tag to the image we built.

On a terminal window, enter the following command

`docker tag customer-order-services:liberty bluedemocluster.icp:8500/purplecompute/customer-order-services:liberty`

This extra information in the tag tells docker that this image belongs to the repository called `purplecompute` on the `bluedemocluster.icp:8500` server. Namespacing is a concept in Kubernetes that allows isolation of applications and other resources.

#### Push image

To make the image available in ICP we need to push the image to ICP's docker images repository. To do so, enter the following command on a terminal window:

1. `docker login bluedemocluster.icp:8500` (providing `admin` as the user and `admin` as the password).
2. `docker push bluedemocluster.icp:8500/purplecompute/customer-order-services:liberty`

   ![Docker 1](/static/imgs/ICp/docker1.png)

   As you can see above, the Docker image did not finish to get pushed into ICP's docker registry. This may happen due to some VM resource contention. Thus, if you didn't succeed at first, just try it again (or few times) until you see that all the layers already exist or haven been pushed:

   ![Docker 2](/static/imgs/ICp/docker2.png)

You will now be able to see the image in the ICP Dashboard:

1. Open Mozilla Firefox and point it to the IBM Cloud Private console: https://10.0.0.1:8443/console

2. If you are still not logged in, you will get redirected to the login page:

   ![Source migration 92](/static/imgs/toLiberty/Source92.png)

   Credentials should be already typed in but, just in case, they are `Username: admin and Password: admin`

3. Once you are authenticated you should finally get to the IBM Cloud Private console:

   ![Source migration 74](/static/imgs/toLiberty/Source74.png)

4. On the ICP web based console, click the hamburger menu icon and select Catalog > Images.

   ![Docker 4](/static/imgs/ICp/docker3.png)

5. Check your Customer Order Services Docker image has been pushed:

   ![Docker 4](/static/imgs/ICp/docker4.png)

   If you see errors when opening the ICP catalog images section, refresh the web browser few times until you see it like in the image above.

### Generate deployment yaml file

Our [deployment yaml file](/static/artifacts/ICP-liberty-tutorial/tutorialConfigFiles/deployment.yaml), which specifies how we want our application (i.e. the container) to be deployed, looks like this:

```
apiVersion: v1
kind: Service
metadata:
  name: customerorderservices
  labels:
    app: customerorderservices
spec:
  ports:
    - port: 80
      targetPort: 9080
  selector:
    app: customerorderservices
  type: NodePort

---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  labels:
    app: customerorderservices
  name: customerorderservices
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: customerorderservices
    spec:
      containers:
      - image: bluedemocluster.icp:8500/purplecompute/customer-order-services:liberty
        name: customerorderservices
        ports:
        - containerPort: 9080
          protocol: TCP
        envFrom:
        - configMapRef:
            name: orderdb
        - configMapRef:
            name: ldap
```

You can see there are two parts in this file, separated by `---`. The three dashes is a yaml construct that allows us to put the content of multiple files in a single file.

Above the dashes is the **Service**, indicated by `kind: Service`. Here we describe how we like the application to be exposed. In our case, we choose to use NodePort, which will expose this service to external traffic. This isn't a secure or recommended way to access your application hosted in a kubernetes-based environment like ICP but for the goal of this tutorial it is acceptable.

The next part is the **deployment** part, indicated by `kind: Deployment`. Here we describe what we want the target state of the application to be. In our example, we instruct a single container to be named `customerorderservices` and created from the image we pushed to our image repository previously.

The envFrom section tells kubernetes to populate the containers environment variables from a ConfigMap, which we will create in Step 5. These variables holds deployment specific information such as database host, port, user and password. This enables us to reuse the same image and deployment manifests in multiple deployment environments such as pre-prod and prod at the same time having their specifics set aside in separate ConfigMap files.

# Next step

Click [here](step5.md) to go to the next step, step 5.

Click [here](tutorial.md) to go to the tutorial initial page.
